extends Node

signal content_update_checked(has_update: bool, version: String)
signal content_updated(success: bool, version: String)

const BUNDLE_CACHE_PATH := "user://content/active_bundle.json"
const BACKUP_BUNDLE_PATH := "user://content_backup/previous_bundle.json"
const VERSION_PATH := "res://data/content_version.json"

var active_version: String = "1.0.0"

func _ready() -> void:
	_init_directories()
	load_local_version()

func _init_directories() -> void:
	if not DirAccess.dir_exists_absolute("user://content"):
		DirAccess.make_dir_absolute("user://content")
	if not DirAccess.dir_exists_absolute("user://content_backup"):
		DirAccess.make_dir_absolute("user://content_backup")

func load_local_version() -> void:
	# Check if cached bundle exists first
	if FileAccess.file_exists(BUNDLE_CACHE_PATH):
		var file := FileAccess.open(BUNDLE_CACHE_PATH, FileAccess.READ)
		if file != null:
			var parsed = JSON.parse_string(file.get_as_text())
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("version"):
				active_version = parsed["version"]
				print("ContentSyncManager: Using cached content bundle version: ", active_version)
				return
				
	# Fallback to bundled release version
	if FileAccess.file_exists(VERSION_PATH):
		var file := FileAccess.open(VERSION_PATH, FileAccess.READ)
		if file != null:
			var parsed = JSON.parse_string(file.get_as_text())
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("version"):
				active_version = parsed["version"]
				print("ContentSyncManager: Using bundled base content version: ", active_version)

func check_for_updates() -> void:
	var net_mgr = get_node_or_null("/root/NetworkManager")
	var api_client = get_node_or_null("/root/ApiClient")
	
	# Never block or attempt if offline
	if net_mgr == null or not net_mgr.is_online() or api_client == null:
		return
		
	var res: Dictionary = await api_client.get_request("content/bundle", {}, 10.0)
	
	if not res.get("success", false):
		print("ContentSyncManager: Content bundle check failed or unavailable. Continuing with local content.")
		content_update_checked.emit(false, active_version)
		return
		
	var bundle_data = res.get("data")
	if typeof(bundle_data) != TYPE_DICTIONARY:
		push_warning("ContentSyncManager: Invalid bundle response format. Retaining existing content.")
		content_update_checked.emit(false, active_version)
		return
		
	var server_version: String = bundle_data.get("version", "")
	if server_version == "" or server_version == active_version:
		content_update_checked.emit(false, active_version)
		return
		
	# Server has a different or newer version: validate before applying
	print("ContentSyncManager: New content bundle detected: ", server_version, " (current: ", active_version, ")")
	if validate_content_bundle(bundle_data):
		apply_content_bundle(bundle_data)
	else:
		push_error("ContentSyncManager: Bundle validation failed! Rejecting downloaded bundle to protect game integrity.")
		content_updated.emit(false, active_version)

func validate_content_bundle(bundle: Dictionary) -> bool:
	if not bundle.has("version"):
		return false
	if not bundle.has("chapters") or typeof(bundle["chapters"]) != TYPE_ARRAY:
		return false
	if not bundle.has("quests") or typeof(bundle["quests"]) != TYPE_ARRAY:
		return false
	if not bundle.has("npcs") or typeof(bundle["npcs"]) != TYPE_ARRAY:
		return false
	if not bundle.has("dialogues") or typeof(bundle["dialogues"]) != TYPE_ARRAY:
		return false
		
	# Ensure chapters has at least Chapter 1
	var chapters: Array = bundle["chapters"]
	if chapters.is_empty():
		return false
		
	return true

func apply_content_bundle(bundle: Dictionary) -> bool:
	_init_directories()
	
	# 1. Backup old cache if present
	if FileAccess.file_exists(BUNDLE_CACHE_PATH):
		var old_file := FileAccess.open(BUNDLE_CACHE_PATH, FileAccess.READ)
		if old_file != null:
			var backup_file := FileAccess.open(BACKUP_BUNDLE_PATH, FileAccess.WRITE)
			if backup_file != null:
				backup_file.store_string(old_file.get_as_text())
				backup_file.close()
			old_file.close()
			
	# 2. Write new bundle to active cache
	var new_file := FileAccess.open(BUNDLE_CACHE_PATH, FileAccess.WRITE)
	if new_file == null:
		push_error("ContentSyncManager: Could not write new content bundle to disk.")
		return false
		
	new_file.store_string(JSON.stringify(bundle, "\t"))
	new_file.close()
	
	active_version = bundle.get("version", active_version)
	print("ContentSyncManager: Content bundle successfully activated: version ", active_version)
	content_updated.emit(true, active_version)
	return true

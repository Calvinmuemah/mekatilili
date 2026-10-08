extends Node

signal sync_started()
signal sync_completed(success: bool, status_message: String)

var is_syncing: bool = false

func _ready() -> void:
	# Listen for auth events to trigger sync if returning player signs in
	if has_node("/root/AuthManager"):
		var auth_mgr = get_node("/root/AuthManager")
		auth_mgr.auth_state_changed.connect(_on_auth_state_changed)

func _on_auth_state_changed(is_logged_in: bool, _user: Dictionary) -> void:
	if is_logged_in and has_node("/root/SaveManager"):
		var save_mgr = get_node("/root/SaveManager")
		if save_mgr.has_save_file():
			var summary: Dictionary = save_mgr.get_save_data_summary()
			sync_progress(summary)

func on_local_save_created(save_data: Dictionary) -> void:
	var net_mgr = get_node_or_null("/root/NetworkManager")
	var auth_mgr = get_node_or_null("/root/AuthManager")
	
	if net_mgr == null or auth_mgr == null:
		return
		
	# Only sync if online and signed in; otherwise stay purely offline
	if net_mgr.is_online() and auth_mgr.is_authenticated():
		sync_progress(save_data)

func sync_progress(local_save: Dictionary = {}) -> void:
	if is_syncing:
		return
		
	var net_mgr = get_node_or_null("/root/NetworkManager")
	var auth_mgr = get_node_or_null("/root/AuthManager")
	var api_client = get_node_or_null("/root/ApiClient")
	var save_mgr = get_node_or_null("/root/SaveManager")
	
	if net_mgr == null or not net_mgr.is_online():
		sync_completed.emit(false, "Saved locally (Offline)")
		return
		
	if auth_mgr == null or not auth_mgr.is_authenticated():
		sync_completed.emit(false, "Saved locally (Guest mode)")
		return
		
	if api_client == null or save_mgr == null:
		return
		
	is_syncing = true
	sync_started.emit()
	
	if local_save.is_empty() and save_mgr.has_save_file():
		local_save = save_mgr.get_save_data_summary()
		
	# 1. Fetch remote progress to compare
	var remote_res: Dictionary = await api_client.get_request("player/progress")
	
	if not remote_res.get("success", false):
		# Push local save directly if no remote progress exists yet or error
		_push_local_save(local_save)
		return
		
	var remote_data: Dictionary = remote_res.get("data", {})
	var remote_prog = remote_data.get("progress", null)
	
	if remote_prog == null:
		# First time cloud sync for this user
		_push_local_save(local_save)
		return
		
	# 2. Conflict Resolution: Compare chapters and timestamps
	var local_chapter: int = local_save.get("chapter", 1)
	var remote_chapter: int = remote_prog.get("current_chapter", 1)
	
	var local_timestamp: String = local_save.get("last_modified_at", local_save.get("timestamp", ""))
	var remote_timestamp: String = remote_prog.get("updated_at", "")
	
	# If remote is strictly further in story, prefer remote but preserve local backup
	if remote_chapter > local_chapter and remote_prog.has("raw_save_data") and not remote_prog["raw_save_data"].is_empty():
		print("SyncManager: Remote cloud save is further ahead. Preserving local backup before update.")
		save_mgr.create_backup()
		
		# Restore remote save data locally
		var raw_cloud = remote_prog["raw_save_data"]
		if typeof(raw_cloud) == TYPE_STRING:
			raw_cloud = JSON.parse_string(raw_cloud)
			
		if typeof(raw_cloud) == TYPE_DICTIONARY and not raw_cloud.is_empty():
			var file := FileAccess.open(save_mgr.SAVE_FILE_PATH, FileAccess.WRITE)
			if file != null:
				raw_cloud["sync_status"] = "SYNCED"
				raw_cloud["last_synced_at"] = Time.get_datetime_string_from_system()
				file.store_string(JSON.stringify(raw_cloud, "\t"))
				file.close()
				
			is_syncing = false
			sync_completed.emit(true, "Cloud progress restored • Local backup saved")
			return
			
	# Otherwise, local save is latest or equal: push local to server
	_push_local_save(local_save)

func _push_local_save(local_save: Dictionary) -> void:
	var api_client = get_node_or_null("/root/ApiClient")
	var save_mgr = get_node_or_null("/root/SaveManager")
	
	if api_client == null or save_mgr == null:
		is_syncing = false
		return
		
	var player_pos: Dictionary = local_save.get("player_position", {"x": 400.0, "y": 350.0})
	var unity: int = local_save.get("community_support", 0)
	var chapter: int = local_save.get("chapter", 1)
	var scene: String = local_save.get("scene", "res://scenes/environments/VillageLevel.tscn")
	var flags: Dictionary = local_save.get("story_flags", {})
	var collectibles: Array = local_save.get("collectibles", [])
	
	# Compute approximate percentage
	var percentage: int = int((float(chapter) / 5.0) * 100.0)
	
	var sync_payload := {
		"chapter": chapter,
		"scene": scene,
		"progressPercentage": percentage,
		"communityUnity": unity,
		"playerPosition": player_pos,
		"rawSaveData": local_save,
		"quests": local_save.get("quests", {}),
		"collectibles": collectibles,
		"storyFlags": flags
	}
	
	var push_res: Dictionary = await api_client.post_request("player/sync", sync_payload)
	is_syncing = false
	
	if push_res.get("success", false):
		var now_iso := Time.get_datetime_string_from_system()
		save_mgr.update_sync_status("SYNCED", now_iso)
		print("SyncManager: Progress synchronized successfully to cloud.")
		sync_completed.emit(true, "Saved • Cloud synced")
	else:
		save_mgr.update_sync_status("FAILED")
		print("SyncManager: Cloud sync failed: ", push_res.get("error", "Unknown error"))
		sync_completed.emit(false, "Saved locally • Cloud sync pending")

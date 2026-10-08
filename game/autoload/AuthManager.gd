extends Node

signal auth_state_changed(is_logged_in: bool, user_info: Dictionary)
signal guest_sync_prompt_requested()

const SESSION_FILE_PATH := "user://auth_session.json"

var current_user: Dictionary = {}
var access_token: String = ""
var is_guest: bool = true

func _ready() -> void:
	load_session()

func is_authenticated() -> bool:
	return access_token != "" and not current_user.is_empty()

func is_guest_mode() -> bool:
	return is_guest or not is_authenticated()

func get_access_token() -> String:
	return access_token

func get_current_user() -> Dictionary:
	return current_user

func continue_as_guest() -> void:
	is_guest = true
	print("AuthManager: Continuing as Guest (Offline-first mode).")

func login(email_or_username: String, password: String) -> Dictionary:
	var api_client = get_node_or_null("/root/ApiClient")
	if api_client == null:
		return {"success": false, "error": "API client unavailable"}
		
	var payload := {
		"emailOrUsername": email_or_username,
		"password": password
	}
	
	var res: Dictionary = await api_client.post_request("auth/login", payload)
	if res.get("success", false) and typeof(res.get("data")) == TYPE_DICTIONARY:
		var data: Dictionary = res["data"]
		var token: String = data.get("accessToken", "")
		var user: Dictionary = data.get("user", {})
		
		save_session(user, token)
		is_guest = false
		
		print("AuthManager: User signed in successfully: ", user.get("username", ""))
		auth_state_changed.emit(true, user)
		
		# Check if local save exists to offer sync
		var save_mgr = get_node_or_null("/root/SaveManager")
		if save_mgr != null and save_mgr.has_save_file():
			guest_sync_prompt_requested.emit()
			
		return {"success": true, "user": user}
	else:
		var err_msg: String = res.get("error", "Login failed")
		return {"success": false, "error": err_msg}

func register(email: String, username: String, password: String, display_name: String = "") -> Dictionary:
	var api_client = get_node_or_null("/root/ApiClient")
	if api_client == null:
		return {"success": false, "error": "API client unavailable"}
		
	var payload := {
		"email": email,
		"username": username,
		"password": password,
		"display_name": display_name if display_name != "" else username
	}
	
	var res: Dictionary = await api_client.post_request("auth/register", payload)
	if res.get("success", false) and typeof(res.get("data")) == TYPE_DICTIONARY:
		var data: Dictionary = res["data"]
		var token: String = data.get("accessToken", "")
		var user: Dictionary = data.get("user", {})
		
		save_session(user, token)
		is_guest = false
		
		print("AuthManager: Account created successfully: ", user.get("username", ""))
		auth_state_changed.emit(true, user)
		
		var save_mgr = get_node_or_null("/root/SaveManager")
		if save_mgr != null and save_mgr.has_save_file():
			guest_sync_prompt_requested.emit()
			
		return {"success": true, "user": user}
	else:
		var err_msg: String = res.get("error", "Registration failed")
		return {"success": false, "error": err_msg}

func logout() -> void:
	clear_session()
	is_guest = true
	print("AuthManager: User signed out.")
	auth_state_changed.emit(false, {})

func save_session(user_data: Dictionary, token: String) -> void:
	current_user = user_data
	access_token = token
	
	var session_dict := {
		"user": current_user,
		"token": access_token,
		"saved_at": Time.get_datetime_string_from_system()
	}
	
	var file := FileAccess.open(SESSION_FILE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(session_dict, "\t"))
		file.close()

func load_session() -> bool:
	if not FileAccess.file_exists(SESSION_FILE_PATH):
		return false
		
	var file := FileAccess.open(SESSION_FILE_PATH, FileAccess.READ)
	if file == null:
		return false
		
	var text := file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("token") and parsed.has("user"):
		access_token = parsed["token"]
		current_user = parsed["user"]
		is_guest = false
		auth_state_changed.emit(true, current_user)
		return true
		
	return false

func clear_session() -> void:
	current_user = {}
	access_token = ""
	if FileAccess.file_exists(SESSION_FILE_PATH):
		DirAccess.remove_absolute(SESSION_FILE_PATH)

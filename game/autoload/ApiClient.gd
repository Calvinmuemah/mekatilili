extends Node

# Signal emitted for network activity (useful for subtle UI activity spinner)
signal request_started(endpoint: String)
signal request_completed_event(endpoint: String, success: bool, status_code: int)

const DEFAULT_BASE_URL := "http://localhost:5000/api/v1"
const CONFIG_PATH := "user://api_config.json"
const DEFAULT_TIMEOUT := 8.0

var base_url: String = DEFAULT_BASE_URL
var auth_token: String = ""

func _ready() -> void:
	load_config()

func load_config() -> void:
	if FileAccess.file_exists(CONFIG_PATH):
		var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
		if file != null:
			var json_text := file.get_as_text()
			var parsed = JSON.parse_string(json_text)
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("base_url"):
				base_url = parsed["base_url"]
				print("ApiClient: Loaded base_url from config: ", base_url)
				return
	base_url = DEFAULT_BASE_URL

func set_base_url(new_url: String) -> void:
	base_url = new_url.rstrip("/")

func set_auth_token(token: String) -> void:
	auth_token = token

func get_auth_token() -> String:
	return auth_token

func clear_auth_token() -> void:
	auth_token = ""

# --- HTTP Request Methods ---

func get_request(endpoint: String, custom_headers: Dictionary = {}, timeout: float = DEFAULT_TIMEOUT) -> Dictionary:
	return await _execute_request(HTTPClient.METHOD_GET, endpoint, {}, custom_headers, timeout)

func post_request(endpoint: String, body: Dictionary = {}, custom_headers: Dictionary = {}, timeout: float = DEFAULT_TIMEOUT) -> Dictionary:
	return await _execute_request(HTTPClient.METHOD_POST, endpoint, body, custom_headers, timeout)

func put_request(endpoint: String, body: Dictionary = {}, custom_headers: Dictionary = {}, timeout: float = DEFAULT_TIMEOUT) -> Dictionary:
	return await _execute_request(HTTPClient.METHOD_PUT, endpoint, body, custom_headers, timeout)

func patch_request(endpoint: String, body: Dictionary = {}, custom_headers: Dictionary = {}, timeout: float = DEFAULT_TIMEOUT) -> Dictionary:
	return await _execute_request(HTTPClient.METHOD_PATCH, endpoint, body, custom_headers, timeout)

func delete_request(endpoint: String, custom_headers: Dictionary = {}, timeout: float = DEFAULT_TIMEOUT) -> Dictionary:
	return await _execute_request(HTTPClient.METHOD_DELETE, endpoint, {}, custom_headers, timeout)

# --- Internal Execution Engine ---

func _execute_request(method: int, endpoint: String, body: Dictionary, custom_headers: Dictionary, timeout: float) -> Dictionary:
	request_started.emit(endpoint)
	
	# Create temporary HTTPRequest node for concurrent safety
	var http_request := HTTPRequest.new()
	http_request.timeout = timeout
	add_child(http_request)
	
	# Prepare headers
	var headers: PackedStringArray = PackedStringArray([
		"Content-Type: application/json",
		"Accept: application/json"
	])
	
	# Inject Auth token if present
	var current_token := auth_token
	if current_token == "" and has_node("/root/AuthManager"):
		var auth_mgr = get_node("/root/AuthManager")
		if auth_mgr != null and auth_mgr.has_method("get_access_token"):
			current_token = auth_mgr.get_access_token()
			
	if current_token != "":
		headers.append("Authorization: Bearer " + current_token)
		
	for k in custom_headers.keys():
		headers.append(str(k) + ": " + str(custom_headers[k]))
		
	# Format URL
	var full_url := base_url + "/" + endpoint.lstrip("/")
	var json_payload := ""
	if method in [HTTPClient.METHOD_POST, HTTPClient.METHOD_PUT, HTTPClient.METHOD_PATCH] and not body.is_empty():
		json_payload = JSON.stringify(body)
		
	# Dispatch request
	var err := http_request.request(full_url, headers, method, json_payload)
	if err != OK:
		http_request.queue_free()
		request_completed_event.emit(endpoint, false, 0)
		return {
			"success": false,
			"status_code": 0,
			"data": null,
			"error": "Failed to initiate HTTP request (Error " + str(err) + ")"
		}
		
	# Await completion
	var response: Array = await http_request.request_completed
	http_request.queue_free()
	
	var result_code: int = response[0]
	var response_code: int = response[1]
	var _response_headers: PackedStringArray = response[2]
	var response_body: PackedByteArray = response[3]
	
	# Check client-side connection result
	if result_code != HTTPRequest.RESULT_SUCCESS:
		var err_msg := "Network error (Code: " + str(result_code) + ")"
		if result_code == HTTPRequest.RESULT_TIMEOUT:
			err_msg = "Request timed out"
		elif result_code == HTTPRequest.RESULT_CANT_CONNECT:
			err_msg = "Could not connect to server"
		request_completed_event.emit(endpoint, false, response_code)
		return {
			"success": false,
			"status_code": response_code,
			"data": null,
			"error": err_msg
		}
		
	# Parse JSON body
	var parsed_data = null
	var body_string := response_body.get_string_from_utf8()
	if body_string.length() > 0:
		parsed_data = JSON.parse_string(body_string)
		
	var is_success := response_code >= 200 and response_code < 300
	var error_msg := ""
	if not is_success:
		if typeof(parsed_data) == TYPE_DICTIONARY and parsed_data.has("error"):
			var err_obj = parsed_data["error"]
			if typeof(err_obj) == TYPE_DICTIONARY and err_obj.has("message"):
				error_msg = str(err_obj["message"])
			else:
				error_msg = str(err_obj)
		else:
			error_msg = "HTTP " + str(response_code)
			
	request_completed_event.emit(endpoint, is_success, response_code)
	
	# If server wraps data in { success: true, data: ... }
	var unwrapped_data = parsed_data
	if typeof(parsed_data) == TYPE_DICTIONARY and parsed_data.has("data"):
		unwrapped_data = parsed_data["data"]
		
	return {
		"success": is_success,
		"status_code": response_code,
		"data": unwrapped_data,
		"raw_response": parsed_data,
		"error": error_msg
	}

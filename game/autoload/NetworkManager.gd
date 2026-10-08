extends Node

enum State {
	UNKNOWN,
	OFFLINE,
	ONLINE
}

signal network_status_changed(new_state: int, previous_state: int)

var current_state: int = State.UNKNOWN
var offline_override: bool = false
var last_checked_time: float = 0.0
var check_interval: float = 30.0
var is_checking: bool = false

var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = check_interval
	_timer.one_shot = false
	_timer.autostart = true
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	
	# Initial background connectivity check after brief engine warmup
	call_deferred("check_connectivity")

func is_online() -> bool:
	if offline_override:
		return false
	return current_state == State.ONLINE

func set_offline_override(enabled: bool) -> void:
	offline_override = enabled
	var prev := current_state
	current_state = State.OFFLINE if enabled else State.UNKNOWN
	if current_state != prev:
		network_status_changed.emit(current_state, prev)
	if not enabled:
		check_connectivity()

func _on_timer_timeout() -> void:
	if not offline_override:
		check_connectivity()

func check_connectivity() -> void:
	if is_checking or offline_override:
		return
		
	is_checking = true
	var previous := current_state
	
	var api_client = get_node_or_null("/root/ApiClient")
	if api_client == null:
		is_checking = false
		return
		
	# Quick health check with small timeout (3.0s)
	var res: Dictionary = await api_client.get_request("health", {}, 3.0)
	
	var new_state: int = State.ONLINE if res.get("success", false) else State.OFFLINE
	current_state = new_state
	is_checking = false
	
	if current_state != previous:
		print("NetworkManager: Status changed to ", "ONLINE" if current_state == State.ONLINE else "OFFLINE")
		network_status_changed.emit(current_state, previous)

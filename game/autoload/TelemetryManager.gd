extends Node

const QUEUE_FILE_PATH := "user://telemetry_queue.json"
const MAX_QUEUE_SIZE := 200

var event_queue: Array = []
var is_flushing: bool = false
var _flush_timer: Timer

func _ready() -> void:
	load_queue()
	_flush_timer = Timer.new()
	_flush_timer.wait_time = 45.0
	_flush_timer.one_shot = false
	_flush_timer.autostart = true
	_flush_timer.timeout.connect(_on_flush_timer_timeout)
	add_child(_flush_timer)
	
	# Connect to network status changes to flush when reconnecting
	if has_node("/root/NetworkManager"):
		var net_mgr = get_node("/root/NetworkManager")
		net_mgr.network_status_changed.connect(_on_network_status_changed)
		
	# Record game launch event
	record_event("GAME_STARTED", {"platform": OS.get_name(), "version": "1.0.0"})

func _on_network_status_changed(new_state: int, _previous: int) -> void:
	if new_state == 2: # ONLINE
		call_deferred("flush_queue")

func _on_flush_timer_timeout() -> void:
	flush_queue()

func record_event(event_type: String, metadata: Dictionary = {}, chapter_id: String = "", quest_id: String = "") -> void:
	var event := {
		"id": "evt_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 1000),
		"event_type": event_type,
		"chapter_id": chapter_id if chapter_id != "" else null,
		"quest_id": quest_id if quest_id != "" else null,
		"metadata": metadata,
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	event_queue.append(event)
	if event_queue.size() > MAX_QUEUE_SIZE:
		event_queue.pop_front() # Evict oldest if queue exceeds maximum
		
	save_queue()
	
	# If online, attempt immediate non-blocking flush
	var net_mgr = get_node_or_null("/root/NetworkManager")
	if net_mgr != null and net_mgr.is_online():
		call_deferred("flush_queue")

func flush_queue() -> void:
	if is_flushing or event_queue.is_empty():
		return
		
	var net_mgr = get_node_or_null("/root/NetworkManager")
	var api_client = get_node_or_null("/root/ApiClient")
	if net_mgr == null or not net_mgr.is_online() or api_client == null:
		return
		
	is_flushing = true
	
	# Dispatch one event at a time or in small batch (up to 5)
	var batch_size: int = mini(5, event_queue.size())
	var events_to_send: Array = []
	for i in range(batch_size):
		events_to_send.append(event_queue[i])
		
	var sent_count := 0
	for evt in events_to_send:
		var payload := {
			"eventType": evt["event_type"],
			"chapterId": evt["chapter_id"],
			"questId": evt["quest_id"],
			"metadata": evt["metadata"]
		}
		
		var res: Dictionary = await api_client.post_request("analytics/event", payload, {}, 5.0)
		if res.get("success", false):
			sent_count += 1
		else:
			# If network failed or errored, stop batch and keep remaining
			break
			
	# Remove successfully sent events from front of queue
	for i in range(sent_count):
		if not event_queue.is_empty():
			event_queue.pop_front()
			
	save_queue()
	is_flushing = false

func save_queue() -> void:
	var file := FileAccess.open(QUEUE_FILE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(event_queue))
		file.close()

func load_queue() -> void:
	if FileAccess.file_exists(QUEUE_FILE_PATH):
		var file := FileAccess.open(QUEUE_FILE_PATH, FileAccess.READ)
		if file != null:
			var parsed = JSON.parse_string(file.get_as_text())
			if typeof(parsed) == TYPE_ARRAY:
				event_queue = parsed
			file.close()

extends Node

signal dialogue_started(dialogue_id: String)
signal dialogue_node_reached(node_data: Dictionary)
signal dialogue_ended(dialogue_id: String)
signal dialogue_event_triggered(event_name: String, event_arg: Variant)

var dialogues_db: Dictionary = {}
var current_dialogue_id: String = ""
var current_node_id: String = ""
var is_active: bool = false

func _ready() -> void:
	load_all_dialogues()

func load_all_dialogues() -> void:
	dialogues_db.clear()
	var dir_path := "res://data/dialogue/"
	if DirAccess.dir_exists_absolute(dir_path):
		var dir := DirAccess.open(dir_path)
		if dir != null:
			dir.list_dir_begin()
			var file_name := dir.get_next()
			while file_name != "":
				if file_name.ends_with(".json"):
					_load_dialogue_file(dir_path + file_name)
				file_name = dir.get_next()
			dir.list_dir_end()

func _load_dialogue_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file != null:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK and typeof(json.data) == TYPE_DICTIONARY:
			var d: Dictionary = json.data
			if d.has("id"):
				dialogues_db[d["id"]] = d
		file.close()

func start_dialogue(dialogue_id: String, start_node: String = "start") -> bool:
	if not dialogues_db.has(dialogue_id):
		push_error("DialogueManager: Dialogue ID not found: " + dialogue_id)
		return false
		
	current_dialogue_id = dialogue_id
	is_active = true
	dialogue_started.emit(dialogue_id)
	
	show_node(start_node)
	return true

func show_node(node_id: String) -> void:
	if not dialogues_db.has(current_dialogue_id):
		end_dialogue()
		return
		
	var d: Dictionary = dialogues_db[current_dialogue_id]
	var nodes: Dictionary = d.get("nodes", {})
	if not nodes.has(node_id):
		end_dialogue()
		return
		
	current_node_id = node_id
	var node_data: Dictionary = nodes[node_id]
	
	# Execute any instant events in this node
	if node_data.has("events") and typeof(node_data["events"]) == TYPE_ARRAY:
		for ev in node_data["events"]:
			_process_event(ev)
			
	dialogue_node_reached.emit(node_data)

func select_choice(choice_index: int) -> void:
	var d: Dictionary = dialogues_db[current_dialogue_id]
	var node_data: Dictionary = d.get("nodes", {}).get(current_node_id, {})
	var choices: Array = node_data.get("choices", [])
	
	if choice_index >= 0 and choice_index < choices.size():
		var choice: Dictionary = choices[choice_index]
		
		# Execute choice events if any
		if choice.has("events") and typeof(choice["events"]) == TYPE_ARRAY:
			for ev in choice["events"]:
				_process_event(ev)
				
		var next_node: String = choice.get("next", "")
		if next_node != "":
			show_node(next_node)
		else:
			end_dialogue()

func next_line() -> void:
	var d: Dictionary = dialogues_db[current_dialogue_id]
	var node_data: Dictionary = d.get("nodes", {}).get(current_node_id, {})
	
	# If choices exist, player must pick a choice instead of pressing next
	if node_data.has("choices") and not node_data["choices"].is_empty():
		return
		
	var next_node: String = node_data.get("next", "")
	if next_node != "":
		show_node(next_node)
	else:
		end_dialogue()

func end_dialogue() -> void:
	var ended_id := current_dialogue_id
	is_active = false
	current_dialogue_id = ""
	current_node_id = ""
	dialogue_ended.emit(ended_id)

func _process_event(ev: Dictionary) -> void:
	var action: String = ev.get("action", "")
	var target: Variant = ev.get("target", null)
	var value: Variant = ev.get("value", null)
	
	dialogue_event_triggered.emit(action, target)
	
	match action:
		"set_flag":
			if StoryManager != null and target is String:
				StoryManager.set_flag(target, value)
		"complete_objective":
			if QuestManager != null and target is String and value is int:
				QuestManager.complete_objective(target, value)
		"advance_objective":
			if QuestManager != null:
				QuestManager.advance_active_objective()
		"start_quest":
			if QuestManager != null and target is String:
				QuestManager.start_quest(target)
		"add_support":
			if StoryManager != null and value is int:
				StoryManager.add_community_support(value)
		"set_support":
			if StoryManager != null and value is int:
				StoryManager.community_support = clampi(value, 0, 100)
				StoryManager.community_support_changed.emit(StoryManager.community_support)
		"journal_entry":
			if StoryManager != null and target is String and value is String:
				StoryManager.add_journal_entry("story", target, value)

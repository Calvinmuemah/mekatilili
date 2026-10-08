extends Node

enum QuestState {
	LOCKED,
	AVAILABLE,
	ACTIVE,
	COMPLETED,
	FAILED
}

signal quest_started(quest_id: String, title: String, description: String)
signal objective_updated(quest_id: String, objective_index: int, description: String)
signal objective_completed(quest_id: String, objective_index: int, description: String)
signal quest_completed(quest_id: String, title: String)

var quests_db: Dictionary = {}
var active_quest_id: String = ""

func _ready() -> void:
	load_all_quests()

func load_all_quests() -> void:
	quests_db.clear()
	var dir_path := "res://data/quests/"
	if DirAccess.dir_exists_absolute(dir_path):
		var dir := DirAccess.open(dir_path)
		if dir != null:
			dir.list_dir_begin()
			var file_name := dir.get_next()
			while file_name != "":
				if file_name.ends_with(".json"):
					_load_quest_file(dir_path + file_name)
				file_name = dir.get_next()
			dir.list_dir_end()
			
	if quests_db.is_empty():
		_load_fallback_quests()

func _load_quest_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file != null:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK and typeof(json.data) == TYPE_DICTIONARY:
			var q: Dictionary = json.data
			if q.has("id"):
				quests_db[q["id"]] = q
		file.close()

func _load_fallback_quests() -> void:
	# Fallback Chapter 1 quest if json not yet created
	var ch1_quest := {
		"id": "quest_chapter_1",
		"title": "Echoes of the Homeland",
		"description": "Unrest stirs in the village of Ulungu as colonial tax collectors draw near. Mekatilili must consult the elders and unite the community.",
		"state": QuestState.AVAILABLE,
		"current_objective_index": 0,
		"objectives": [
			{
				"id": "talk_nyevu",
				"description": "Speak with Villager Nyevu about the colonial tax notice.",
				"completed": false
			},
			{
				"id": "inspect_crops",
				"description": "Check the village Shamba and harvest traditional cassava.",
				"completed": false
			},
			{
				"id": "consult_mzee_fondo",
				"description": "Consult Elder Mzee Fondo at the Council Baobab.",
				"completed": false
			},
			{
				"id": "find_wanje",
				"description": "Seek out Wanje wa Mwadorikola near the Kaya border.",
				"completed": false
			},
			{
				"id": "gather_community",
				"description": "Convene the village gathering at the council fire.",
				"completed": false
			}
		],
		"reward_text": "Community united in defiance; 50 Community Support gained."
	}
	quests_db["quest_chapter_1"] = ch1_quest

func start_quest(quest_id: String) -> bool:
	if not quests_db.has(quest_id):
		push_error("QuestManager: Quest ID not found: " + quest_id)
		return false
		
	var q: Dictionary = quests_db[quest_id]
	q["state"] = QuestState.ACTIVE
	q["current_objective_index"] = 0
	active_quest_id = quest_id
	
	if AudioManager != null:
		AudioManager.play_sfx("sfx_quest_start")
		
	quest_started.emit(quest_id, q.get("title", ""), q.get("description", ""))
	
	var first_obj: String = get_current_objective_text()
	objective_updated.emit(quest_id, 0, first_obj)
	
	if StoryManager != null:
		StoryManager.add_journal_entry("quests", q.get("title", ""), "Active Quest: " + q.get("description", ""))
		
	return true

func get_active_quest() -> Dictionary:
	if active_quest_id != "" and quests_db.has(active_quest_id):
		return quests_db[active_quest_id]
	return {}

func get_current_objective_text() -> String:
	var q := get_active_quest()
	if q.is_empty():
		return "Explore the village of Ulungu."
	var objs: Array = q.get("objectives", [])
	var idx: int = q.get("current_objective_index", 0)
	if idx >= 0 and idx < objs.size():
		return objs[idx].get("description", "")
	return "All objectives complete."

func complete_objective(quest_id: String, objective_index: int) -> void:
	if not quests_db.has(quest_id):
		return
	var q: Dictionary = quests_db[quest_id]
	var objs: Array = q.get("objectives", [])
	if objective_index >= 0 and objective_index < objs.size():
		if not objs[objective_index].get("completed", false):
			objs[objective_index]["completed"] = true
			var desc: String = objs[objective_index].get("description", "")
			objective_completed.emit(quest_id, objective_index, desc)
			
			if AudioManager != null:
				AudioManager.play_sfx("sfx_quest_complete")
				
			var next_idx := objective_index + 1
			q["current_objective_index"] = next_idx
			if next_idx < objs.size():
				var next_desc: String = objs[next_idx].get("description", "")
				objective_updated.emit(quest_id, next_idx, next_desc)
			else:
				complete_quest(quest_id)

func advance_active_objective() -> void:
	if active_quest_id != "":
		var q: Dictionary = quests_db[active_quest_id]
		var idx: int = q.get("current_objective_index", 0)
		complete_objective(active_quest_id, idx)

func complete_quest(quest_id: String) -> void:
	if not quests_db.has(quest_id):
		return
	var q: Dictionary = quests_db[quest_id]
	q["state"] = QuestState.COMPLETED
	
	if AudioManager != null:
		AudioManager.play_sfx("sfx_quest_complete", 1.1)
		
	quest_completed.emit(quest_id, q.get("title", ""))
	
	if StoryManager != null:
		StoryManager.add_journal_entry("quests", q.get("title", "") + " [Completed]", q.get("reward_text", "Quest successfully completed."))
		StoryManager.add_community_support(50)
		
	if active_quest_id == quest_id:
		active_quest_id = ""

func serialize_state() -> Dictionary:
	return {
		"active_quest_id": active_quest_id,
		"quests": quests_db.duplicate(true)
	}

func deserialize_state(data: Dictionary) -> void:
	if data.has("quests") and typeof(data["quests"]) == TYPE_DICTIONARY:
		quests_db = data["quests"]
	if data.has("active_quest_id"):
		active_quest_id = data["active_quest_id"]

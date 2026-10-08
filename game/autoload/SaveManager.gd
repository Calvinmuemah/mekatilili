extends Node

const SAVE_FILE_PATH := "user://save_game.json"
const SAVE_VERSION := 1

signal save_completed(success: bool)
signal load_completed(success: bool)

var default_settings: Dictionary = {
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sfx_volume": 0.9,
	"text_speed": 1.0,
	"show_tutorials": true,
	"text_size_multiplier": 1.0,
	"touch_controls_visible": true
}

var current_settings: Dictionary = default_settings.duplicate()

func _ready() -> void:
	load_settings()

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func get_save_data_summary() -> Dictionary:
	if not has_save_file():
		return {}
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var json_str := file.get_as_text()
	var test_json := JSON.new()
	if test_json.parse(json_str) == OK and typeof(test_json.data) == TYPE_DICTIONARY:
		return test_json.data
	return {}

func save_game(custom_data: Dictionary = {}) -> bool:
	var player_pos := Vector2.ZERO
	if GameManager.player_node != null and is_instance_valid(GameManager.player_node):
		player_pos = GameManager.player_node.global_position
	
	var save_dict: Dictionary = {
		"version": SAVE_VERSION,
		"timestamp": Time.get_datetime_string_from_system(),
		"chapter": GameManager.current_chapter,
		"scene": GameManager.current_scene_path,
		"player_position": {
			"x": player_pos.x,
			"y": player_pos.y
		},
		"quests": QuestManager.serialize_state() if QuestManager != null else {},
		"story_flags": StoryManager.story_flags if StoryManager != null else {},
		"collectibles": StoryManager.collectibles if StoryManager != null else [],
		"journal": StoryManager.serialize_journal() if StoryManager != null else {},
		"community_support": StoryManager.community_support if StoryManager != null else 0,
		"settings": current_settings
	}
	
	# Merge any extra custom overrides
	for k in custom_data.keys():
		save_dict[k] = custom_data[k]
		
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Failed to open save file for writing at " + SAVE_FILE_PATH)
		save_completed.emit(false)
		return false
		
	var json_string := JSON.stringify(save_dict, "\t")
	file.store_string(json_string)
	file.close()
	print("SaveManager: Game saved successfully.")
	save_completed.emit(true)
	return true

func load_game() -> bool:
	if not has_save_file():
		print("SaveManager: No save file found.")
		load_completed.emit(false)
		return false
		
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: Failed to open save file.")
		load_completed.emit(false)
		return false
		
	var content := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_result := json.parse(content)
	if parse_result != OK:
		push_error("SaveManager: Failed to parse save file JSON.")
		load_completed.emit(false)
		return false
		
	var data: Dictionary = json.data
	# Version migration check
	var version: int = data.get("version", 1)
	if version > SAVE_VERSION:
		push_warning("SaveManager: Save data is from a newer version.")
	
	# Restore state
	if data.has("settings") and typeof(data["settings"]) == TYPE_DICTIONARY:
		current_settings = data["settings"]
		apply_settings()
		
	if StoryManager != null:
		if data.has("story_flags"):
			StoryManager.story_flags = data["story_flags"]
		if data.has("collectibles"):
			StoryManager.collectibles = data["collectibles"]
		if data.has("journal"):
			StoryManager.deserialize_journal(data["journal"])
		if data.has("community_support"):
			StoryManager.community_support = data["community_support"]
			
	if QuestManager != null and data.has("quests"):
		QuestManager.deserialize_state(data["quests"])
		
	var target_scene: String = data.get("scene", "res://scenes/environments/VillageLevel.tscn")
	var target_pos := Vector2(
		data.get("player_position", {}).get("x", 400.0),
		data.get("player_position", {}).get("y", 350.0)
	)
	
	GameManager.current_chapter = data.get("chapter", 1)
	GameManager.saved_player_position = target_pos
	
	SceneManager.change_scene(target_scene)
	load_completed.emit(true)
	return true

func delete_save() -> bool:
	if has_save_file():
		var err := DirAccess.remove_absolute(SAVE_FILE_PATH)
		if err == OK:
			print("SaveManager: Save file removed.")
			return true
	return false

func save_settings() -> void:
	var path := "user://settings.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(current_settings, "\t"))
		file.close()

func load_settings() -> void:
	var path := "user://settings.json"
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file != null:
			var json := JSON.new()
			if json.parse(file.get_as_text()) == OK and typeof(json.data) == TYPE_DICTIONARY:
				for k in json.data.keys():
					current_settings[k] = json.data[k]
			file.close()
	apply_settings()

func apply_settings() -> void:
	if AudioManager != null:
		AudioManager.set_master_volume(current_settings.get("master_volume", 1.0))
		AudioManager.set_music_volume(current_settings.get("music_volume", 0.8))
		AudioManager.set_sfx_volume(current_settings.get("sfx_volume", 0.9))

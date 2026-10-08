extends Node

enum GameState {
	BOOT,
	MAIN_MENU,
	IN_GAME,
	CUTSCENE,
	PAUSED
}

signal game_state_changed(new_state: GameState)
signal pause_toggled(is_paused: bool)
signal chapter_started(chapter_num: int, chapter_title: String)
signal chapter_completed(chapter_num: int)

var current_state: GameState = GameState.BOOT
var current_chapter: int = 1
var current_scene_path: String = ""
var player_node: Node2D = null
var saved_player_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_input_actions_if_missing()

func _setup_input_actions_if_missing() -> void:
	var actions := {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"interact": [KEY_E, KEY_SPACE, KEY_ENTER],
		"journal": [KEY_J, KEY_TAB],
		"pause": [KEY_ESCAPE]
	}
	
	for action_name in actions.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			for key_code in actions[action_name]:
				var ev := InputEventKey.new()
				ev.physical_keycode = key_code
				InputMap.action_add_event(action_name, ev)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if current_state == GameState.IN_GAME or current_state == GameState.PAUSED:
			toggle_pause()

func set_game_state(new_state: GameState) -> void:
	current_state = new_state
	game_state_changed.emit(new_state)

func start_new_game() -> void:
	current_chapter = 1
	saved_player_position = Vector2.ZERO
	if StoryManager != null:
		StoryManager.reset_state()
	if QuestManager != null:
		QuestManager.load_all_quests()
	
	set_game_state(GameState.CUTSCENE)
	SceneManager.change_scene("res://scenes/cinematics/IntroCinematic.tscn")

func continue_game() -> void:
	if SaveManager != null and SaveManager.has_save_file():
		set_game_state(GameState.IN_GAME)
		SaveManager.load_game()
	else:
		start_new_game()

func toggle_pause() -> void:
	if current_state == GameState.CUTSCENE:
		return # Cannot pause during non-interactive cutscene
		
	var is_paused := not get_tree().paused
	get_tree().paused = is_paused
	
	if is_paused:
		set_game_state(GameState.PAUSED)
	else:
		set_game_state(GameState.IN_GAME)
		
	pause_toggled.emit(is_paused)

func resume_game() -> void:
	if get_tree().paused:
		get_tree().paused = false
		set_game_state(GameState.IN_GAME)
		pause_toggled.emit(false)

func complete_current_chapter() -> void:
	chapter_completed.emit(current_chapter)
	# Chapter completion modal/scene
	SceneManager.change_scene("res://scenes/ui/ChapterComplete.tscn")

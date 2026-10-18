class_name KifuduGathering
extends Node2D

@onready var player: PlayerController = $Player
@onready var hud: HUD = $HUD
@onready var chapter_intro_panel: Panel = $HUD/ChapterIntroPanel
@onready var chapter_intro_title: Label = $HUD/ChapterIntroPanel/VBox/Title
@onready var chapter_intro_sub: Label = $HUD/ChapterIntroPanel/VBox/Subtitle
@onready var council_stone_interactable: Interactable = $CouncilStone/Interactable
@onready var departure_interactable: Interactable = $DepartureCaravan/Interactable
@onready var drum_timer: Timer = $DrumTimer

func _ready() -> void:
	if GameManager != null:
		GameManager.set_game_state(GameManager.GameState.IN_GAME)
		GameManager.current_level = 5
		GameManager.current_scene_path = scene_file_path
		
	if AudioManager != null:
		AudioManager.play_ambient("res://assets/audio/ambient_coastal_loop.wav")
		AudioManager.play_sfx("sfx_drum")
		
	_setup_camera_limits()
	_show_level_intro()
	
	if SaveManager != null:
		SaveManager.save_game({"chapter": 2, "level": 5})
	
	if council_stone_interactable != null:
		council_stone_interactable.prompt_message = "Address the Assembly"
		council_stone_interactable.interacted.connect(_on_council_stone_interacted)
		
	if departure_interactable != null:
		departure_interactable.prompt_message = "March to Kwa Junda"
		departure_interactable.is_interactable = false
		departure_interactable.interacted.connect(_on_departure_interacted)
		
	if DialogueManager != null:
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
		
	# Periodic drum rhythm
	if drum_timer != null:
		drum_timer.timeout.connect(_on_drum_beat)
		drum_timer.start(2.5)

func _setup_camera_limits() -> void:
	if player != null:
		var cam: Camera2D = player.get_node_or_null("Camera2D")
		if cam != null:
			cam.limit_left = 0
			cam.limit_top = 0
			cam.limit_right = 1280
			cam.limit_bottom = 800

func _show_level_intro() -> void:
	if chapter_intro_panel != null:
		var style := GamePalette.create_panel_style(GamePalette.COLOR_DEEP_EARTH, GamePalette.COLOR_WARM_GOLD, 12, 3)
		chapter_intro_panel.add_theme_stylebox_override("panel", style)
		chapter_intro_title.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
		chapter_intro_title.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_H1)
		chapter_intro_title.text = "LEVEL 5"
		chapter_intro_sub.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)
		chapter_intro_sub.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_BODY)
		chapter_intro_sub.text = "The Kifudu Gathering at Kaya Fungo"
		
		chapter_intro_panel.modulate.a = 0.0
		var tween := create_tween()
		tween.tween_property(chapter_intro_panel, "modulate:a", 1.0, 0.6)
		tween.tween_interval(2.2)
		tween.tween_property(chapter_intro_panel, "modulate:a", 0.0, 0.6)
		tween.tween_callback(func(): chapter_intro_panel.visible = false)

func _on_drum_beat() -> void:
	if AudioManager != null:
		AudioManager.play_sfx("sfx_drum", randf_range(0.95, 1.05))

func _on_council_stone_interacted(_interactor: Node2D) -> void:
	if DialogueManager != null:
		DialogueManager.start_dialogue("dialogue_kifudu_speech")

func _on_dialogue_ended(dialogue_id: String) -> void:
	if dialogue_id == "dialogue_kifudu_speech":
		if council_stone_interactable != null:
			council_stone_interactable.is_interactable = false
		if departure_interactable != null:
			departure_interactable.is_interactable = true
			departure_interactable.set_focused(true)
			
		var hud_node := get_tree().get_first_node_in_group("hud")
		if hud_node != null and hud_node.has_method("show_collectible_banner"):
			hud_node.show_collectible_banner(
				"The Assembly is United!",
				"The covenant is sworn! Head to the southern departure road to march to Arthur Champion's station at Kwa Junda."
			)

func _on_departure_interacted(_interactor: Node2D) -> void:
	if GameManager != null:
		GameManager.current_level = 6
	SceneManager.change_scene("res://scenes/environments/ColonialStation.tscn")

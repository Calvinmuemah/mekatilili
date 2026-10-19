class_name KisiiPrison
extends Node2D

@onready var player: PlayerController = $Player
@onready var hud: HUD = $HUD
@onready var chapter_intro_panel: Panel = $HUD/ChapterIntroPanel
@onready var chapter_intro_title: Label = $HUD/ChapterIntroPanel/VBox/Title
@onready var chapter_intro_sub: Label = $HUD/ChapterIntroPanel/VBox/Subtitle

@onready var wanje_interactable: Interactable = $WanjeCell/Interactable
@onready var key_interactable: Interactable = $WardenPost/Interactable
@onready var north_gate_interactable: Interactable = $NorthGate/Interactable
@onready var cell_door_sprite: ColorRect = $WanjeCell/CellDoor

var has_key: bool = false
var wanje_freed: bool = false

func _ready() -> void:
	if GameManager != null:
		GameManager.set_game_state(GameManager.GameState.IN_GAME)
		GameManager.current_level = 9
		GameManager.current_scene_path = scene_file_path

	if AudioManager != null:
		AudioManager.play_ambient("res://assets/audio/ambient_coastal_loop.wav")
		AudioManager.play_music("res://assets/audio/music_intro_loop.wav")

	_setup_camera_limits()
	_show_intro_banner("CHAPTER III: LEVEL 9 & 10", "The Shadows of Kisii — Prison Breakout")

	if QuestManager != null:
		QuestManager.start_quest("quest_level_9")

	if SaveManager != null:
		SaveManager.save_game({"chapter": 3, "level": 9, "scene": scene_file_path})

	# Setup interactables
	if wanje_interactable != null:
		wanje_interactable.prompt_message = "Whisper to Wanje"
		wanje_interactable.interacted.connect(_on_wanje_interacted)

	if key_interactable != null:
		key_interactable.prompt_message = "Seize Warden's Keys"
		key_interactable.interacted.connect(_on_key_interacted)

	if north_gate_interactable != null:
		north_gate_interactable.prompt_message = "Inspect North Gate"
		north_gate_interactable.interacted.connect(_on_north_gate_interacted)

	if DialogueManager != null:
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _setup_camera_limits() -> void:
	if player != null:
		var cam: Camera2D = player.get_node_or_null("Camera2D")
		if cam != null:
			cam.limit_left = 0
			cam.limit_top = 0
			cam.limit_right = 1600
			cam.limit_bottom = 1100

func _show_intro_banner(title: String, subtitle: String) -> void:
	if chapter_intro_panel != null:
		var style := GamePalette.create_panel_style(GamePalette.COLOR_DEEP_EARTH, GamePalette.COLOR_WARM_GOLD, 12, 3)
		chapter_intro_panel.add_theme_stylebox_override("panel", style)
		chapter_intro_title.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
		chapter_intro_title.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_H1)
		chapter_intro_title.text = title
		chapter_intro_sub.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)
		chapter_intro_sub.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_BODY)
		chapter_intro_sub.text = subtitle

		chapter_intro_panel.modulate.a = 0.0
		chapter_intro_panel.visible = true
		var tween := create_tween()
		tween.tween_property(chapter_intro_panel, "modulate:a", 1.0, 0.8)
		tween.tween_interval(2.5)
		tween.tween_property(chapter_intro_panel, "modulate:a", 0.0, 0.8)
		tween.tween_callback(func(): chapter_intro_panel.visible = false)

func _on_wanje_interacted(_interactor: Node2D) -> void:
	if not wanje_freed:
		if has_key:
			wanje_freed = true
			if cell_door_sprite != null:
				cell_door_sprite.visible = false
			if AudioManager != null:
				AudioManager.play_sfx("sfx_quest_complete")
			if DialogueManager != null:
				DialogueManager.start_dialogue("dialogue_kisii_breakout")
			if north_gate_interactable != null:
				north_gate_interactable.prompt_message = "Escape Northern Gate"
				north_gate_interactable.marker_type = "quest"
		else:
			if DialogueManager != null:
				DialogueManager.start_dialogue("dialogue_kisii_wanje")
	else:
		if hud != null and hud.has_method("show_collectible_banner"):
			hud.show_collectible_banner("Wanje is Free", "Sprint north to the gate while the sentries look away!")

func _on_key_interacted(_interactor: Node2D) -> void:
	if has_key:
		return
	has_key = true
	key_interactable.is_interactable = false
	var key_sprite := $WardenPost/KeySprite as Sprite2D
	if key_sprite != null:
		key_sprite.visible = false

	if AudioManager != null:
		AudioManager.play_sfx("sfx_item_collect")

	if QuestManager != null:
		QuestManager.complete_objective("quest_level_9", 1)

	if StoryManager != null:
		StoryManager.set_flag("has_prison_key", true)
		StoryManager.add_journal_entry("story", "Seizing the Warden's Key", "Mekatilili infiltrated the colonial warden's post and secured the stockade iron keys.")

	if hud != null and hud.has_method("show_collectible_banner"):
		hud.show_collectible_banner("Iron Keys Acquired", "Return to Wanje's detention cell to unlock his iron bars.")

	if wanje_interactable != null:
		wanje_interactable.prompt_message = "Unlock Wanje's Cell"

func _on_north_gate_interacted(_interactor: Node2D) -> void:
	if not wanje_freed:
		if hud != null and hud.has_method("show_collectible_banner"):
			hud.show_collectible_banner("Gate Locked", "You cannot leave Wanje behind! Find his cell and retrieve the warden's keys first.")
		return

	# Advance to Level 11 - The Thousand-Kilometer Walk Home
	if GameManager != null:
		GameManager.current_level = 11
	if SaveManager != null:
		SaveManager.save_game({"chapter": 3, "level": 11, "scene": "res://scenes/environments/WildernessTrek.tscn"})
	if SceneManager != null:
		SceneManager.change_scene("res://scenes/environments/WildernessTrek.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/environments/WildernessTrek.tscn")

func _on_dialogue_ended(dialogue_id: String) -> void:
	if dialogue_id == "dialogue_kisii_wanje":
		if QuestManager != null:
			QuestManager.complete_objective("quest_level_9", 0)
		if key_interactable != null:
			key_interactable.marker_type = "quest"
	elif dialogue_id == "dialogue_kisii_breakout":
		if GameManager != null:
			GameManager.current_level = 10
		if QuestManager != null:
			QuestManager.start_quest("quest_level_10")

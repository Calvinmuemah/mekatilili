class_name ArrestSequence
extends Node2D

@onready var hud: HUD = $HUD
@onready var dialogue_box: DialogueBox = $HUD/DialogueBox
@onready var map_panel: Panel = $HUD/MapPanel
@onready var map_title: Label = $HUD/MapPanel/VBox/Title
@onready var map_desc: RichTextLabel = $HUD/MapPanel/VBox/Desc
@onready var proceed_btn: Button = $HUD/MapPanel/VBox/ProceedBtn

func _ready() -> void:
	if GameManager != null:
		GameManager.set_game_state(GameManager.GameState.CUTSCENE)
		GameManager.current_level = 8
		GameManager.current_scene_path = scene_file_path

	if AudioManager != null:
		AudioManager.play_ambient("res://assets/audio/ambient_coastal_loop.wav")
		AudioManager.play_music("res://assets/audio/music_intro_loop.wav")

	if map_panel != null:
		map_panel.visible = false
		_style_map_panel()

	if proceed_btn != null:
		proceed_btn.pressed.connect(_on_proceed_pressed)

	if DialogueManager != null:
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	# Start Level 8 quest and launch arrest dialogue
	if QuestManager != null:
		QuestManager.start_quest("quest_level_8")

	# Small delay before opening dialogue
	var timer := get_tree().create_timer(0.6)
	timer.timeout.connect(func():
		if DialogueManager != null:
			DialogueManager.start_dialogue("dialogue_arrest")
	)

func _style_map_panel() -> void:
	var style := GamePalette.create_panel_style(GamePalette.COLOR_DEEP_EARTH, GamePalette.COLOR_WARM_GOLD, 14, 3)
	map_panel.add_theme_stylebox_override("panel", style)
	map_title.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
	map_title.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_H1)
	map_desc.add_theme_color_override("default_color", GamePalette.COLOR_IVORY)
	map_desc.add_theme_font_size_override("normal_font_size", GamePalette.FONT_SIZE_BODY)
	GamePalette.apply_button_theme(proceed_btn, GamePalette.COLOR_TERRACOTTA, GamePalette.FONT_SIZE_BUTTON)

func _on_dialogue_ended(dialogue_id: String) -> void:
	if dialogue_id == "dialogue_arrest":
		_show_banishment_interlude()

func _show_banishment_interlude() -> void:
	if map_panel == null:
		_transition_to_kisii()
		return

	map_title.text = "THE 1,000-KILOMETER BANISHMENT"
	map_desc.text = "[b]October 1913 — British East Africa Protectorate[/b]\n\n"
	map_desc.text += "Fearing Mekatilili's influence on the coastal clans, District Commissioner Arthur Champion sentenced both Mekatilili and Wanje to banishment.\n\n"
	map_desc.text += "They were marched under heavy armed guard across Kenya: from the tropical palms of Kilifi, through the arid Taru desert, ascending the Great Rift Valley, to the fortified stockade of [b]Kisii Prison[/b] near Lake Victoria.\n\n"
	map_desc.text += "[color=#D9A441][i]The British believed they had silenced the rebellion forever. They did not know the unbreakable resolve of Mekatilili wa Menza.[/i][/color]"
	
	map_panel.visible = true
	map_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(map_panel, "modulate:a", 1.0, 0.6)

func _on_proceed_pressed() -> void:
	_transition_to_kisii()

func _transition_to_kisii() -> void:
	if GameManager != null:
		GameManager.current_level = 9
	if SaveManager != null:
		SaveManager.save_game({"chapter": 3, "level": 9, "scene": "res://scenes/environments/KisiiPrison.tscn"})
	if SceneManager != null:
		SceneManager.change_scene("res://scenes/environments/KisiiPrison.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/environments/KisiiPrison.tscn")

class_name ColonialStation
extends Node2D

@onready var player: PlayerController = $Player
@onready var hud: HUD = $HUD
@onready var champion_npc: NPCController = $NPCChampion
@onready var hen_node: Node2D = $HenChicks
@onready var south_gate_area: Area2D = $SouthExitGate
@onready var sentries_container: Node2D = $Sentries
@onready var chapter_intro_panel: Panel = $HUD/ChapterIntroPanel
@onready var chapter_intro_title: Label = $HUD/ChapterIntroPanel/VBox/Title
@onready var chapter_intro_sub: Label = $HUD/ChapterIntroPanel/VBox/Subtitle

var hen_animated: bool = false
var chase_started: bool = false

func _ready() -> void:
	if GameManager != null:
		GameManager.set_game_state(GameManager.GameState.IN_GAME)
		GameManager.current_level = 6
		GameManager.current_scene_path = scene_file_path
		
	if AudioManager != null:
		AudioManager.play_ambient("res://assets/audio/ambient_coastal_loop.wav")
		AudioManager.play_music("res://assets/audio/music_intro_loop.wav")
		
	_setup_camera_limits()
	_show_level_intro()
	
	if SaveManager != null:
		SaveManager.save_game({"chapter": 2, "level": 6})
	
	if hen_node != null:
		hen_node.visible = false
		
	if south_gate_area != null:
		south_gate_area.body_entered.connect(_on_south_gate_entered)
		
	if DialogueManager != null:
		DialogueManager.dialogue_node_reached.connect(_on_dialogue_node_reached)
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
		
	if QuestManager != null:
		var q := QuestManager.get_active_quest()
		if q.is_empty() or q.get("id", "") != "quest_level_6":
			QuestManager.start_quest("quest_level_6")

func _setup_camera_limits() -> void:
	if player != null:
		var cam: Camera2D = player.get_node_or_null("Camera2D")
		if cam != null:
			cam.limit_left = 0
			cam.limit_top = 0
			cam.limit_right = 1400
			cam.limit_bottom = 900

func _show_level_intro() -> void:
	if chapter_intro_panel != null:
		var style := GamePalette.create_panel_style(GamePalette.COLOR_DEEP_EARTH, GamePalette.COLOR_WARM_GOLD, 12, 3)
		chapter_intro_panel.add_theme_stylebox_override("panel", style)
		chapter_intro_title.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
		chapter_intro_title.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_H1)
		chapter_intro_title.text = "LEVEL 6 & 7"
		chapter_intro_sub.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)
		chapter_intro_sub.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_BODY)
		chapter_intro_sub.text = "The Colonial Station & The Hen Chase"
		
		chapter_intro_panel.modulate.a = 0.0
		var tween := create_tween()
		tween.tween_property(chapter_intro_panel, "modulate:a", 1.0, 0.6)
		tween.tween_interval(2.2)
		tween.tween_property(chapter_intro_panel, "modulate:a", 0.0, 0.6)
		tween.tween_callback(func(): chapter_intro_panel.visible = false)

func _on_dialogue_node_reached(node_data: Dictionary) -> void:
	# Trigger hen release animation when the player delivers the hen
	if not hen_animated and StoryManager != null and StoryManager.has_flag("hen_released"):
		_play_hen_release_event()

func _play_hen_release_event() -> void:
	hen_animated = true
	if hen_node != null:
		hen_node.visible = true
		hen_node.global_position = Vector2(700, 280)
		
		if AudioManager != null:
			AudioManager.play_sfx("sfx_hen", 1.0)
			
		var tween := create_tween()
		# Hen rushes towards Champion's boots
		tween.tween_property(hen_node, "global_position", Vector2(700, 245), 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		# Flutters and pecks
		tween.tween_property(hen_node, "rotation_degrees", 15.0, 0.1)
		tween.tween_property(hen_node, "rotation_degrees", -15.0, 0.1)
		tween.tween_property(hen_node, "rotation_degrees", 0.0, 0.1)
		tween.tween_callback(func():
			if AudioManager != null:
				AudioManager.play_sfx("sfx_hen", 1.2)
		)

func _on_dialogue_ended(dialogue_id: String) -> void:
	if dialogue_id == "dialogue_arthur_champion":
		_start_chase_sequence()

func _start_chase_sequence() -> void:
	if chase_started:
		return
	chase_started = true
	
	if GameManager != null:
		GameManager.current_level = 7
		
	if StoryManager != null:
		StoryManager.set_flag("chase_active", true)
		
	if AudioManager != null:
		AudioManager.play_sfx("sfx_whistle", 1.1)
		
	# Trigger all sentries to pursuit mode
	if sentries_container != null:
		for sentry in sentries_container.get_children():
			if sentry.has_method("set_chase_mode"):
				sentry.set_chase_mode(true)
				
	var hud_node := get_tree().get_first_node_in_group("hud")
	if hud_node != null and hud_node.has_method("show_collectible_banner"):
		hud_node.show_collectible_banner(
			"CHASE ACTIVE: EVADE THE GUARDS!",
			"The compound is on full alert! Evade the sentries and sprint to the South Exit Gate!"
		)

func _on_south_gate_entered(body: Node2D) -> void:
	if body is PlayerController and chase_started:
		# Complete Level 7 chase objective!
		if QuestManager != null:
			QuestManager.complete_objective("quest_level_6", 2)
			
		if AudioManager != null:
			AudioManager.play_sfx("sfx_quest_complete", 1.2)
			
		if StoryManager != null:
			StoryManager.add_journal_entry(
				"story",
				"Escape from Kwa Junda",
				"Mekatilili and Wanje defied District Commissioner Arthur Champion and evaded the colonial sentries, escaping through the southern gates back into the Giriama hinterland."
			)
			
		# Advance to Level 8 transition
		if GameManager != null:
			GameManager.current_level = 8
			GameManager.complete_current_chapter()

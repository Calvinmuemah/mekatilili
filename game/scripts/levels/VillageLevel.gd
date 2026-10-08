class_name VillageLevel
extends Node2D

@onready var player: PlayerController = $Player
@onready var hud: HUD = $HUD
@onready var chapter_intro_panel: Panel = $HUD/ChapterIntroPanel
@onready var chapter_intro_title: Label = $HUD/ChapterIntroPanel/VBox/Title
@onready var chapter_intro_sub: Label = $HUD/ChapterIntroPanel/VBox/Subtitle

func _ready() -> void:
	if GameManager != null:
		GameManager.set_game_state(GameManager.GameState.IN_GAME)
		GameManager.current_chapter = 1
		GameManager.current_scene_path = scene_file_path
		
	if AudioManager != null:
		AudioManager.play_ambient("res://assets/audio/ambient_coastal_loop.wav")
		AudioManager.play_music("res://assets/audio/music_intro_loop.wav")
		
	_setup_camera_limits()
	_start_chapter_progression()

func _setup_camera_limits() -> void:
	if player != null:
		var cam: Camera2D = player.get_node_or_null("Camera2D")
		if cam != null:
			cam.limit_left = 0
			cam.limit_top = 0
			cam.limit_right = 1600
			cam.limit_bottom = 1200

func _start_chapter_progression() -> void:
	# Show Chapter 1 intro card
	if chapter_intro_panel != null:
		var style := GamePalette.create_panel_style(GamePalette.COLOR_DEEP_EARTH, GamePalette.COLOR_WARM_GOLD, 12, 3)
		chapter_intro_panel.add_theme_stylebox_override("panel", style)
		chapter_intro_title.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
		chapter_intro_title.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_H1)
		chapter_intro_sub.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)
		chapter_intro_sub.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_BODY)
		
		chapter_intro_panel.modulate.a = 0.0
		var tween := create_tween()
		tween.tween_property(chapter_intro_panel, "modulate:a", 1.0, 0.8)
		tween.tween_interval(2.5)
		tween.tween_property(chapter_intro_panel, "modulate:a", 0.0, 0.8)
		tween.tween_callback(func(): chapter_intro_panel.visible = false)
		
	# Start quest if not active
	if QuestManager != null:
		var q := QuestManager.get_active_quest()
		if q.is_empty():
			QuestManager.start_quest("quest_chapter_1")

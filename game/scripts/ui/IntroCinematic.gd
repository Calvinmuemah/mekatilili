class_name IntroCinematic
extends Control

@onready var background: TextureRect = $Background
@onready var narrative_label: Label = $TextPanel/NarrativeLabel
@onready var title_banner: Label = $TitleBanner
@onready var skip_btn: Button = $SkipBtn

var story_beats: Array[String] = [
	"Kenya, 1913. Along the sun-drenched coastal ridges, the Agiriama people have lived in harmony with their ancestral soils for generations.",
	"In the sacred Kayas—the ancient fortified forests—the elders uphold sacred traditions, community freedom, and ancient laws.",
	"Then came the foreign shadow. The British colonial administration demanded forced plantation labor, heavy hut taxes, and surrender of the youth.",
	"In the village of Ulungu, an elder widow and visionary woman watched the encroaching injustice.",
	"Her name is Mekatilili wa Menza. She refused to let her people kneel."
]

var current_beat: int = 0
var tween: Tween

func _ready() -> void:
	_style_cinematic()
	
	if AudioManager != null:
		AudioManager.play_music("res://assets/audio/music_intro_loop.wav")
		AudioManager.play_ambient("res://assets/audio/ambient_coastal_loop.wav")
		
	skip_btn.pressed.connect(_on_skip_pressed)
	_play_beat(0)

	if SaveManager != null and SaveManager.has_signal("settings_changed"):
		SaveManager.settings_changed.connect(_style_cinematic)

func _style_cinematic() -> void:
	narrative_label.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)
	narrative_label.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_DIALOGUE + 2))
	
	title_banner.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
	title_banner.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_CHAPTER))
	
	var panel: Panel = $TextPanel
	var style := GamePalette.create_panel_style(GamePalette.COLOR_DEEP_EARTH, GamePalette.COLOR_WARM_GOLD, 10, 2)
	panel.add_theme_stylebox_override("panel", style)
	
	GamePalette.apply_button_theme(skip_btn, GamePalette.COLOR_TERRACOTTA, GamePalette.FONT_SIZE_BODY)

func _play_beat(idx: int) -> void:
	if idx >= story_beats.size():
		_finish_cinematic()
		return
		
	current_beat = idx
	narrative_label.text = story_beats[idx]
	narrative_label.modulate.a = 0.0
	
	if AudioManager != null and AudioManager.has_method("speak_text"):
		AudioManager.speak_text(story_beats[idx], "Narrator")
	
	if tween != null and tween.is_valid():
		tween.kill()
		
	tween = create_tween()
	# Subtle zoom on background
	var target_scale := Vector2(1.0 + idx * 0.04, 1.0 + idx * 0.04)
	tween.tween_property(background, "scale", target_scale, 5.0)
	tween.parallel().tween_property(narrative_label, "modulate:a", 1.0, 0.8)
	tween.tween_interval(3.8)
	tween.tween_property(narrative_label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): _play_beat(idx + 1))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.is_pressed():
			# Advance to next beat on click/tap
			if current_beat + 1 < story_beats.size():
				_play_beat(current_beat + 1)
			else:
				_finish_cinematic()

func _on_skip_pressed() -> void:
	_finish_cinematic()

func _finish_cinematic() -> void:
	if AudioManager != null and AudioManager.has_method("stop_voiceover"):
		AudioManager.stop_voiceover()
	if tween != null and tween.is_valid():
		tween.kill()
	if GameManager != null:
		GameManager.set_game_state(GameManager.GameState.IN_GAME)
	SceneManager.change_scene("res://scenes/environments/VillageLevel.tscn", 0.6)

class_name SettingsMenu
extends Control

@onready var panel: Panel = $Panel
@onready var master_slider: HSlider = $Panel/VBox/MasterRow/MasterSlider
@onready var music_slider: HSlider = $Panel/VBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $Panel/VBox/SfxRow/SfxSlider
@onready var tutorial_check: CheckButton = $Panel/VBox/TutorialRow/TutorialCheck
@onready var reset_btn: Button = $Panel/VBox/ResetBtn
@onready var close_btn: Button = $Panel/CloseBtn

func _ready() -> void:
	visible = false
	_style_settings()
	_load_current_values()
	
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	tutorial_check.toggled.connect(_on_tutorial_toggled)
	reset_btn.pressed.connect(_on_reset_pressed)
	close_btn.pressed.connect(_on_close_pressed)

func _style_settings() -> void:
	var style := GamePalette.create_panel_style(GamePalette.COLOR_SAND, GamePalette.COLOR_WARM_GOLD, 12, 3)
	panel.add_theme_stylebox_override("panel", style)
	
	GamePalette.apply_button_theme(close_btn, GamePalette.COLOR_DEEP_EARTH)
	GamePalette.apply_button_theme(reset_btn, GamePalette.COLOR_TERRACOTTA)

func _load_current_values() -> void:
	if SaveManager != null:
		master_slider.value = SaveManager.current_settings.get("master_volume", 1.0) * 100.0
		music_slider.value = SaveManager.current_settings.get("music_volume", 0.8) * 100.0
		sfx_slider.value = SaveManager.current_settings.get("sfx_volume", 0.9) * 100.0
		tutorial_check.button_pressed = SaveManager.current_settings.get("show_tutorials", true)

func _on_master_changed(val: float) -> void:
	var norm := val / 100.0
	if SaveManager != null:
		SaveManager.current_settings["master_volume"] = norm
		SaveManager.apply_settings()

func _on_music_changed(val: float) -> void:
	var norm := val / 100.0
	if SaveManager != null:
		SaveManager.current_settings["music_volume"] = norm
		SaveManager.apply_settings()

func _on_sfx_changed(val: float) -> void:
	var norm := val / 100.0
	if SaveManager != null:
		SaveManager.current_settings["sfx_volume"] = norm
		SaveManager.apply_settings()

func _on_tutorial_toggled(val: bool) -> void:
	if SaveManager != null:
		SaveManager.current_settings["show_tutorials"] = val

func _on_reset_pressed() -> void:
	if SaveManager != null:
		SaveManager.delete_save()
	if StoryManager != null:
		StoryManager.reset_state()
	visible = false

func _on_close_pressed() -> void:
	if SaveManager != null:
		SaveManager.save_settings()
	visible = false

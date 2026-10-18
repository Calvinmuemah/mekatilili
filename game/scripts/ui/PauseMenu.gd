class_name PauseMenu
extends Control

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var resume_btn: Button = $Panel/VBox/ResumeBtn
@onready var journal_btn: Button = $Panel/VBox/JournalBtn
@onready var settings_btn: Button = $Panel/VBox/SettingsBtn
@onready var save_btn: Button = $Panel/VBox/SaveBtn
@onready var menu_btn: Button = $Panel/VBox/MenuBtn
@onready var status_label: Label = $Panel/VBox/StatusLabel

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_style_pause_menu()
	
	resume_btn.pressed.connect(_on_resume_pressed)
	journal_btn.pressed.connect(_on_journal_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	save_btn.pressed.connect(_on_save_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	
	if GameManager != null:
		GameManager.pause_toggled.connect(func(is_paused: bool):
			visible = is_paused
			status_label.text = ""
		)
		
	if SaveManager != null and SaveManager.has_signal("settings_changed"):
		SaveManager.settings_changed.connect(_style_pause_menu)

func _style_pause_menu() -> void:
	var style := GamePalette.create_panel_style(GamePalette.COLOR_SAND, GamePalette.COLOR_WARM_GOLD, 12, 3)
	panel.add_theme_stylebox_override("panel", style)
	
	title_label.add_theme_color_override("font_color", GamePalette.COLOR_DEEP_EARTH)
	title_label.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_H1))
	status_label.add_theme_color_override("font_color", GamePalette.COLOR_FOREST_GREEN)
	status_label.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_CAPTION))
	
	GamePalette.apply_button_theme(resume_btn, GamePalette.COLOR_TERRACOTTA, GamePalette.FONT_SIZE_BODY)
	GamePalette.apply_button_theme(journal_btn, GamePalette.COLOR_FOREST_GREEN, GamePalette.FONT_SIZE_BODY)
	GamePalette.apply_button_theme(settings_btn, GamePalette.COLOR_DEEP_EARTH, GamePalette.FONT_SIZE_BODY)
	GamePalette.apply_button_theme(save_btn, GamePalette.COLOR_WARM_GOLD, GamePalette.FONT_SIZE_BODY)
	GamePalette.apply_button_theme(menu_btn, GamePalette.COLOR_CHARCOAL, GamePalette.FONT_SIZE_BODY)

func _on_resume_pressed() -> void:
	if GameManager != null:
		GameManager.resume_game()

func _on_journal_pressed() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("toggle_journal"):
		hud.toggle_journal()

func _on_settings_pressed() -> void:
	var settings_popup := get_tree().get_first_node_in_group("settings_menu")
	if settings_popup != null:
		settings_popup.visible = true

func _on_save_pressed() -> void:
	if SaveManager != null:
		var ok := SaveManager.save_game()
		if ok:
			status_label.text = "Game progress saved successfully."
			if AudioManager != null:
				AudioManager.play_sfx("sfx_item_collect")
		else:
			status_label.text = "Failed to save game."

func _on_menu_pressed() -> void:
	if GameManager != null:
		GameManager.resume_game() # unpause tree
		GameManager.set_game_state(GameManager.GameState.MAIN_MENU)
	SceneManager.change_scene("res://scenes/main/MainMenu.tscn")

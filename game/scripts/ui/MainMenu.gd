class_name MainMenu
extends Control

@onready var continue_btn: Button = $CenterVBox/Buttons/ContinueBtn
@onready var new_game_btn: Button = $CenterVBox/Buttons/NewGameBtn
@onready var settings_btn: Button = $CenterVBox/Buttons/SettingsBtn
@onready var about_btn: Button = $CenterVBox/Buttons/AboutBtn

@onready var confirm_dialog: Control = $ConfirmDialog
@onready var confirm_begin_btn: Button = $ConfirmDialog/Panel/VBox/HBox/BeginBtn
@onready var confirm_back_btn: Button = $ConfirmDialog/Panel/VBox/HBox/BackBtn

@onready var about_dialog: Control = $AboutDialog
@onready var about_close_btn: Button = $AboutDialog/Panel/CloseBtn

@onready var settings_menu: Control = $SettingsMenu

func _ready() -> void:
	if GameManager != null:
		GameManager.set_game_state(GameManager.GameState.MAIN_MENU)
		
	if AudioManager != null:
		AudioManager.play_music("res://assets/audio/music_intro_loop.wav")
		AudioManager.play_ambient("res://assets/audio/ambient_coastal_loop.wav")
		
	_style_main_menu()
	_check_save_state()
	
	continue_btn.pressed.connect(_on_continue_pressed)
	new_game_btn.pressed.connect(_on_new_game_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	about_btn.pressed.connect(_on_about_pressed)
	
	confirm_begin_btn.pressed.connect(_on_begin_journey_confirmed)
	confirm_back_btn.pressed.connect(func(): confirm_dialog.visible = false)
	about_close_btn.pressed.connect(func(): about_dialog.visible = false)

func _style_main_menu() -> void:
	var title_lbl: Label = $CenterVBox/Header/TitleLabel
	title_lbl.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
	title_lbl.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_H1 + 8)
	
	var sub_lbl: Label = $CenterVBox/Header/SubtitleLabel
	sub_lbl.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)
	sub_lbl.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_BODY)
	
	GamePalette.apply_button_theme(continue_btn, GamePalette.COLOR_FOREST_GREEN)
	GamePalette.apply_button_theme(new_game_btn, GamePalette.COLOR_TERRACOTTA)
	GamePalette.apply_button_theme(settings_btn, GamePalette.COLOR_DEEP_EARTH)
	GamePalette.apply_button_theme(about_btn, GamePalette.COLOR_DEEP_EARTH)
	
	# Confirmation styling
	var confirm_panel: Panel = $ConfirmDialog/Panel
	var c_style := GamePalette.create_panel_style(GamePalette.COLOR_SAND, GamePalette.COLOR_WARM_GOLD, 12, 3)
	confirm_panel.add_theme_stylebox_override("panel", c_style)
	GamePalette.apply_button_theme(confirm_begin_btn, GamePalette.COLOR_TERRACOTTA)
	GamePalette.apply_button_theme(confirm_back_btn, GamePalette.COLOR_CHARCOAL)
	
	# About panel styling
	var about_panel: Panel = $AboutDialog/Panel
	about_panel.add_theme_stylebox_override("panel", c_style)
	GamePalette.apply_button_theme(about_close_btn, GamePalette.COLOR_DEEP_EARTH)

func _check_save_state() -> void:
	var has_save := false
	if SaveManager != null:
		has_save = SaveManager.has_save_file()
	continue_btn.disabled = not has_save

func _on_continue_pressed() -> void:
	if AudioManager != null:
		AudioManager.play_sfx("sfx_click")
	if GameManager != null:
		GameManager.continue_game()

func _on_new_game_pressed() -> void:
	if AudioManager != null:
		AudioManager.play_sfx("sfx_click")
	confirm_dialog.visible = true

func _on_begin_journey_confirmed() -> void:
	confirm_dialog.visible = false
	if AudioManager != null:
		AudioManager.play_sfx("sfx_click")
	if GameManager != null:
		GameManager.start_new_game()

func _on_settings_pressed() -> void:
	if AudioManager != null:
		AudioManager.play_sfx("sfx_click")
	settings_menu.visible = true

func _on_about_pressed() -> void:
	if AudioManager != null:
		AudioManager.play_sfx("sfx_click")
	about_dialog.visible = true

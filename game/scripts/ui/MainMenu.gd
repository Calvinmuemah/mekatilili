class_name MainMenu
extends Control

@onready var continue_btn: Button = $CenterVBox/Buttons/ContinueBtn
@onready var new_game_btn: Button = $CenterVBox/Buttons/NewGameBtn
@onready var settings_btn: Button = $CenterVBox/Buttons/SettingsBtn
@onready var account_btn: Button = $CenterVBox/Buttons/AccountBtn
@onready var about_btn: Button = $CenterVBox/Buttons/AboutBtn

@onready var confirm_dialog: Control = $ConfirmDialog
@onready var confirm_begin_btn: Button = $ConfirmDialog/Panel/VBox/HBox/BeginBtn
@onready var confirm_back_btn: Button = $ConfirmDialog/Panel/VBox/HBox/BackBtn

@onready var about_dialog: Control = $AboutDialog
@onready var about_close_btn: Button = $AboutDialog.find_child("CloseBtn", true, false) as Button

@onready var settings_menu: Control = $SettingsMenu
@onready var auth_dialog: Control = $AuthDialog
@onready var profile_pill: Button = $TopStatusBar/ProfilePill
@onready var status_dot: Label = $TopStatusBar/NetworkIndicator/StatusDot
@onready var status_text: Label = $TopStatusBar/NetworkIndicator/StatusText
@onready var save_info_label: Label = get_node_or_null("CenterVBox/Buttons/SaveInfoLabel")
@onready var chronicle_card: Panel = get_node_or_null("ChronicleCard")
@onready var chronicle_fact: RichTextLabel = get_node_or_null("ChronicleCard/VBox/FactText")
@onready var chronicle_title: Label = get_node_or_null("ChronicleCard/VBox/Header/Title")

const HISTORICAL_FACTS: Array[String] = [
	"In August 1913, [b]Mekatilili wa Menza[/b] rallied the Agiriama at sacred [b]Kaya Fungo[/b], organizing resistance against British forced labor and hut taxes.",
	"The Agiriama elders swore the solemn [b]Mukushe[/b] and [b]Kifudu[/b] oaths, uniting nine coastal clans in sacred solidarity.",
	"Exiled 1,000 km away to Kisii, Mekatilili and [b]Wanje wa Madorika[/b] heroically escaped and walked back on foot through dense wilderness.",
	"The sacred [b]Kaya Forests[/b] remain UNESCO World Heritage cultural sanctuaries, preserving centuries of coastal botanical and spiritual heritage."
]
var chronicle_index: int = 0
var chronicle_timer: float = 0.0
const CHRONICLE_INTERVAL: float = 8.5

func _ready() -> void:
	if GameManager != null:
		GameManager.set_game_state(GameManager.GameState.MAIN_MENU)
		
	if AudioManager != null:
		AudioManager.play_music("res://assets/audio/music_intro_loop.wav")
		AudioManager.play_ambient("res://assets/audio/ambient_coastal_loop.wav")
		
	_style_main_menu()
	_check_save_state()
	_update_auth_ui()
	_update_network_ui()
	_setup_button_hover_effects()
	
	continue_btn.pressed.connect(_on_continue_pressed)
	new_game_btn.pressed.connect(_on_new_game_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	account_btn.pressed.connect(_on_account_pressed)
	about_btn.pressed.connect(_on_about_pressed)
	profile_pill.pressed.connect(_on_profile_pill_pressed)
	
	confirm_begin_btn.pressed.connect(_on_begin_journey_confirmed)
	confirm_back_btn.pressed.connect(func(): confirm_dialog.visible = false)
	about_close_btn.pressed.connect(func(): about_dialog.visible = false)
	
	if chronicle_card != null:
		chronicle_card.gui_input.connect(_on_chronicle_gui_input)
	
	if NetworkManager != null:
		NetworkManager.network_status_changed.connect(func(_new_s, _prev_s): _update_network_ui())
	if AuthManager != null:
		AuthManager.auth_state_changed.connect(func(_logged_in, _user): _update_auth_ui())
		
	if SaveManager != null and SaveManager.has_signal("settings_changed"):
		SaveManager.settings_changed.connect(_style_main_menu)

func _process(delta: float) -> void:
	if chronicle_card != null and chronicle_fact != null:
		chronicle_timer += delta
		if chronicle_timer >= CHRONICLE_INTERVAL:
			chronicle_timer = 0.0
			_cycle_chronicle()

func _setup_button_hover_effects() -> void:
	var buttons := [continue_btn, new_game_btn, settings_btn, account_btn, about_btn, profile_pill]
	for btn: Button in buttons:
		if btn == null:
			continue
		btn.pivot_offset = btn.custom_minimum_size / 2.0
		btn.mouse_entered.connect(_on_btn_hover.bind(btn))
		btn.mouse_exited.connect(_on_btn_unhover.bind(btn))
		btn.focus_entered.connect(_on_btn_hover.bind(btn))
		btn.focus_exited.connect(_on_btn_unhover.bind(btn))

func _on_btn_hover(btn: Button) -> void:
	if btn.disabled:
		return
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2(1.03, 1.03), 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_btn_unhover(btn: Button) -> void:
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_chronicle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.is_pressed():
			chronicle_timer = 0.0
			_cycle_chronicle()

func _cycle_chronicle() -> void:
	if chronicle_fact == null:
		return
	var tween := create_tween()
	tween.tween_property(chronicle_fact, "modulate:a", 0.0, 0.25)
	tween.tween_callback(func():
		chronicle_index = (chronicle_index + 1) % HISTORICAL_FACTS.size()
		chronicle_fact.text = HISTORICAL_FACTS[chronicle_index]
	)
	tween.tween_property(chronicle_fact, "modulate:a", 1.0, 0.3)

func _style_main_menu() -> void:
	var title_lbl: Label = get_node_or_null("TopHeader/TitleLabel")
	if title_lbl == null:
		title_lbl = get_node_or_null("CenterVBox/Header/TitleLabel")
	if title_lbl != null:
		title_lbl.add_theme_color_override("font_color", Color("#FFE299"))
		title_lbl.add_theme_color_override("font_shadow_color", Color("#1A0D06"))
		title_lbl.add_theme_constant_override("shadow_offset_x", 3)
		title_lbl.add_theme_constant_override("shadow_offset_y", 3)
		title_lbl.add_theme_color_override("font_outline_color", Color("#26140A"))
		title_lbl.add_theme_constant_override("outline_size", 4)
		title_lbl.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_H1 + 8))
	
	var sub_lbl: Label = get_node_or_null("TopHeader/SubtitleLabel")
	if sub_lbl == null:
		sub_lbl = get_node_or_null("CenterVBox/Header/SubtitleLabel")
	if sub_lbl != null:
		sub_lbl.add_theme_color_override("font_color", Color("#FFF7E6"))
		sub_lbl.add_theme_color_override("font_shadow_color", Color("#1A0D06"))
		sub_lbl.add_theme_constant_override("shadow_offset_x", 2)
		sub_lbl.add_theme_constant_override("shadow_offset_y", 2)
		sub_lbl.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BODY + 2))
		
	var orn_lbl: Label = get_node_or_null("TopHeader/OrnamentLabel")
	if orn_lbl != null:
		orn_lbl.add_theme_color_override("font_color", Color("#D9A441"))
		orn_lbl.add_theme_color_override("font_shadow_color", Color("#1A0D06"))
		orn_lbl.add_theme_constant_override("shadow_offset_x", 1)
		orn_lbl.add_theme_constant_override("shadow_offset_y", 1)
		orn_lbl.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_CAPTION))

	var footer_lbl: Label = get_node_or_null("Footer")
	if footer_lbl != null:
		footer_lbl.add_theme_color_override("font_color", GamePalette.COLOR_SAND)
		footer_lbl.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_CAPTION))
	
	GamePalette.apply_button_theme(continue_btn, GamePalette.COLOR_FOREST_GREEN, GamePalette.FONT_SIZE_BUTTON + 2)
	GamePalette.apply_button_theme(new_game_btn, GamePalette.COLOR_TERRACOTTA, GamePalette.FONT_SIZE_BUTTON + 2)
	GamePalette.apply_button_theme(settings_btn, GamePalette.COLOR_DEEP_EARTH, GamePalette.FONT_SIZE_BUTTON + 2)
	GamePalette.apply_button_theme(account_btn, GamePalette.COLOR_DEEP_EARTH, GamePalette.FONT_SIZE_BUTTON + 2)
	GamePalette.apply_button_theme(about_btn, GamePalette.COLOR_DEEP_EARTH, GamePalette.FONT_SIZE_BUTTON + 2)
	GamePalette.apply_button_theme(profile_pill, GamePalette.COLOR_WARM_GOLD, GamePalette.FONT_SIZE_CAPTION + 1)
	
	# Chronicle Card styling
	if chronicle_card != null:
		var ch_style := GamePalette.create_panel_style(Color(0.12, 0.08, 0.05, 0.85), GamePalette.COLOR_WARM_GOLD, 8, 2)
		chronicle_card.add_theme_stylebox_override("panel", ch_style)
	if chronicle_title != null:
		chronicle_title.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
		chronicle_title.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_CAPTION))
	if chronicle_fact != null:
		chronicle_fact.add_theme_color_override("default_color", GamePalette.COLOR_IVORY)
		chronicle_fact.add_theme_font_size_override("normal_font_size", GamePalette.get_scaled_font_size(12))
	
	# Confirmation styling
	var confirm_panel: Panel = $ConfirmDialog/Panel
	var c_style := GamePalette.create_panel_style(GamePalette.COLOR_SAND, GamePalette.COLOR_WARM_GOLD, 12, 3)
	confirm_panel.add_theme_stylebox_override("panel", c_style)
	var confirm_lbl: Label = $ConfirmDialog.find_child("Label", true, false) as Label
	if confirm_lbl != null:
		confirm_lbl.add_theme_color_override("font_color", GamePalette.COLOR_CHARCOAL)
		confirm_lbl.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BODY + 2))
	GamePalette.apply_button_theme(confirm_begin_btn, GamePalette.COLOR_TERRACOTTA, GamePalette.FONT_SIZE_BUTTON + 1)
	GamePalette.apply_button_theme(confirm_back_btn, GamePalette.COLOR_CHARCOAL, GamePalette.FONT_SIZE_BUTTON + 1)
	
	# About panel styling
	var about_panel: Panel = $AboutDialog/Panel
	about_panel.add_theme_stylebox_override("panel", c_style)
	if about_close_btn != null:
		GamePalette.apply_button_theme(about_close_btn, GamePalette.COLOR_DEEP_EARTH, GamePalette.FONT_SIZE_BUTTON)
	var about_title: Label = $AboutDialog.find_child("Title", true, false) as Label
	if about_title != null:
		about_title.add_theme_color_override("font_color", Color("#8C3518"))
		about_title.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_H2))
	var about_desc: RichTextLabel = $AboutDialog.find_child("Desc", true, false) as RichTextLabel
	if about_desc != null:
		about_desc.add_theme_color_override("default_color", GamePalette.COLOR_CHARCOAL)
		about_desc.add_theme_font_size_override("normal_font_size", GamePalette.get_scaled_font_size(15))

func _check_save_state() -> void:
	var has_save := false
	var summary: Dictionary = {}
	if SaveManager != null:
		has_save = SaveManager.has_save_file()
		summary = SaveManager.get_save_data_summary()
		
	# Ensure the button is never disabled so player taps always register
	continue_btn.disabled = false
	
	if has_save and not summary.is_empty():
		var chapter: int = summary.get("chapter", 1)
		var level: int = summary.get("level", 1)
		var unity: int = summary.get("community_support", 0)
		var ch3_done: bool = summary.get("chapter_3_completed", false) or level >= 12
		var ch2_done: bool = summary.get("chapter_2_completed", false) or level >= 8
		
		if ch3_done:
			continue_btn.text = "▶  REPLAY FULL SAGA (LEVELS 1–11)"
			if save_info_label != null:
				save_info_label.visible = true
				save_info_label.text = "✦ Chapters I, II & III Complete  •  All 11 Levels Conquered!"
				save_info_label.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
		elif ch2_done and level >= 8:
			continue_btn.text = "▶  CONTINUE CHAPTER III (LEVEL %d)" % level
			if save_info_label != null:
				save_info_label.visible = true
				save_info_label.text = "✦ Chapter 3 (Level %d)  •  Banishment & Trek" % level
				save_info_label.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
		else:
			continue_btn.text = "▶  CONTINUE JOURNEY"
			if save_info_label != null:
				save_info_label.visible = true
				save_info_label.text = "✦ Chapter %d (Level %d)  •  Community Unity: %d%%" % [chapter, level, unity]
				save_info_label.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
	else:
		continue_btn.text = "▶  CONTINUE JOURNEY"
		if save_info_label != null:
			save_info_label.visible = true
			save_info_label.text = "✦ Tap to begin your historical journey"
			save_info_label.add_theme_color_override("font_color", GamePalette.COLOR_SAND)

func _update_network_ui() -> void:
	if NetworkManager == null:
		return
	var online: bool = NetworkManager.is_online()
	status_dot.add_theme_color_override("font_color", GamePalette.COLOR_FOREST_GREEN if online else GamePalette.COLOR_SAND)
	status_text.text = "Online" if online else "Offline"
	status_text.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)

func _update_auth_ui() -> void:
	if AuthManager == null:
		return
	var is_auth := AuthManager.is_authenticated()
	if is_auth:
		var user: Dictionary = AuthManager.get_current_user()
		var dname: String = user.get("display_name", user.get("username", "Explorer"))
		profile_pill.visible = true
		profile_pill.text = "👤 " + dname
		account_btn.text = "☁  ACCOUNT & CLOUD"
	else:
		profile_pill.visible = false
		account_btn.text = "☁  ACCOUNT & SYNC"

func _on_account_pressed() -> void:
	if AudioManager != null:
		AudioManager.play_sfx("sfx_click")
	auth_dialog.visible = true

func _on_profile_pill_pressed() -> void:
	if AudioManager != null:
		AudioManager.play_sfx("sfx_click")
	# If signed in, quick cloud sync trigger
	if SyncManager != null:
		SyncManager.sync_progress()
	auth_dialog.visible = true

func _on_continue_pressed() -> void:
	if AudioManager != null:
		AudioManager.play_sfx("sfx_click")
	if GameManager != null:
		if SaveManager != null and SaveManager.has_save_file():
			var summary := SaveManager.get_save_data_summary()
			var ch3_done: bool = summary.get("chapter_3_completed", false) or summary.get("level", 1) >= 12
			if ch3_done:
				GameManager.start_new_game()
			else:
				GameManager.continue_game()
		else:
			GameManager.start_new_game()



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


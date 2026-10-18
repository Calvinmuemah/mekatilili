class_name SettingsMenu
extends Control

@onready var panel: Panel = get_node_or_null("Panel")
@onready var vbox: VBoxContainer = find_child("VBox", true, false) as VBoxContainer
@onready var master_slider: HSlider = find_child("MasterSlider", true, false) as HSlider
@onready var music_slider: HSlider = find_child("MusicSlider", true, false) as HSlider
@onready var sfx_slider: HSlider = find_child("SfxSlider", true, false) as HSlider
@onready var tutorial_check: CheckButton = find_child("TutorialCheck", true, false) as CheckButton
@onready var reset_btn: Button = find_child("ResetBtn", true, false) as Button
@onready var close_btn: Button = find_child("CloseBtn", true, false) as Button

var master_label: Label = null
var music_label: Label = null
var sfx_label: Label = null
var large_text_check: CheckButton = null
var instant_check: CheckButton = null
var high_contrast_check: CheckButton = null
var voiceover_check: CheckButton = null

func _ready() -> void:
	visible = false
	var master_row: Control = find_child("MasterRow", true, false)
	if master_row != null:
		master_label = master_row.find_child("Label", true, false) as Label
	var music_row: Control = find_child("MusicRow", true, false)
	if music_row != null:
		music_label = music_row.find_child("Label", true, false) as Label
	var sfx_row: Control = find_child("SfxRow", true, false)
	if sfx_row != null:
		sfx_label = sfx_row.find_child("Label", true, false) as Label

	_build_accessibility_ui()
	_style_settings()
	_load_current_values()
	
	if master_slider != null: master_slider.value_changed.connect(_on_master_changed)
	if music_slider != null: music_slider.value_changed.connect(_on_music_changed)
	if sfx_slider != null: sfx_slider.value_changed.connect(_on_sfx_changed)
	if tutorial_check != null: tutorial_check.toggled.connect(_on_tutorial_toggled)
	if reset_btn != null: reset_btn.pressed.connect(_on_reset_pressed)
	if close_btn != null: close_btn.pressed.connect(_on_close_pressed)
	
	if SaveManager != null and SaveManager.has_signal("settings_changed"):
		SaveManager.settings_changed.connect(_style_settings)

func _build_accessibility_ui() -> void:
	if vbox == null:
		return
		
	# Voiceover / Read Aloud (Enabled by default as requested)
	var row_vo := _create_toggle_row("Voiceover (Read Aloud)", "voiceover_enabled", true)
	voiceover_check = row_vo[1]
	vbox.add_child(row_vo[0])
	if reset_btn != null:
		vbox.move_child(row_vo[0], reset_btn.get_index())
	voiceover_check.toggled.connect(_on_voiceover_toggled)
		
	# Large Text Mode (Elderly / Accessibility)
	var row_lt := _create_toggle_row("Large Text (Elderly Mode)", "large_text", true)
	large_text_check = row_lt[1]
	vbox.add_child(row_lt[0])
	if reset_btn != null:
		vbox.move_child(row_lt[0], reset_btn.get_index())
	large_text_check.toggled.connect(_on_large_text_toggled)
	
	# Instant Dialogue Option (No moving typewriter text)
	var row_inst := _create_toggle_row("Instant Dialogue Text", "instant_dialogue", false)
	instant_check = row_inst[1]
	vbox.add_child(row_inst[0])
	if reset_btn != null:
		vbox.move_child(row_inst[0], reset_btn.get_index())
	instant_check.toggled.connect(_on_instant_dialogue_toggled)
	
	# High Contrast Mode
	var row_hc := _create_toggle_row("High Contrast UI", "high_contrast", false)
	high_contrast_check = row_hc[1]
	vbox.add_child(row_hc[0])
	if reset_btn != null:
		vbox.move_child(row_hc[0], reset_btn.get_index())
	high_contrast_check.toggled.connect(_on_high_contrast_toggled)

func _create_toggle_row(title: String, setting_key: String, default_val: bool) -> Array:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	
	var lbl := Label.new()
	lbl.text = title
	lbl.custom_minimum_size = Vector2(180, 0)
	lbl.add_theme_color_override("font_color", GamePalette.COLOR_DEEP_EARTH)
	lbl.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BODY))
	row.add_child(lbl)
	
	var check := CheckButton.new()
	var val: bool = default_val
	if SaveManager != null:
		val = SaveManager.current_settings.get(setting_key, default_val)
	check.button_pressed = val
	row.add_child(check)
	
	return [row, check]

func _style_settings() -> void:
	if panel != null:
		var style := GamePalette.create_panel_style(GamePalette.COLOR_SAND, GamePalette.COLOR_WARM_GOLD, 12, 3)
		panel.add_theme_stylebox_override("panel", style)
	
	if close_btn != null:
		GamePalette.apply_button_theme(close_btn, GamePalette.COLOR_DEEP_EARTH, GamePalette.FONT_SIZE_BODY)
	if reset_btn != null:
		GamePalette.apply_button_theme(reset_btn, GamePalette.COLOR_TERRACOTTA, GamePalette.FONT_SIZE_BODY)
	
	var header_lbl: Label = find_child("HeaderLabel", true, false) as Label
	if header_lbl != null:
		header_lbl.add_theme_color_override("font_color", Color("#8C3518"))
		header_lbl.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_H2))
	
	# Ensure all labels in vbox have readable colors and scaled sizes
	if vbox != null:
		for child in vbox.get_children():
			if child is HBoxContainer:
				for sub in child.get_children():
					if sub is Label:
						sub.add_theme_color_override("font_color", GamePalette.COLOR_DEEP_EARTH)
						sub.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BODY))

func _load_current_values() -> void:
	if SaveManager != null:
		var mv: float = SaveManager.current_settings.get("master_volume", 1.0) * 100.0
		var mu: float = SaveManager.current_settings.get("music_volume", 0.8) * 100.0
		var sv: float = SaveManager.current_settings.get("sfx_volume", 0.9) * 100.0
		master_slider.value = mv
		music_slider.value = mu
		sfx_slider.value = sv
		if master_label != null: master_label.text = "Master: %d%%" % int(mv)
		if music_label != null: music_label.text = "Music: %d%%" % int(mu)
		if sfx_label != null: sfx_label.text = "SFX: %d%%" % int(sv)
		tutorial_check.button_pressed = SaveManager.current_settings.get("show_tutorials", true)
		if voiceover_check != null:
			voiceover_check.button_pressed = SaveManager.current_settings.get("voiceover_enabled", true)
		if large_text_check != null:
			large_text_check.button_pressed = SaveManager.current_settings.get("large_text", true)
		if instant_check != null:
			instant_check.button_pressed = SaveManager.current_settings.get("instant_dialogue", false)
		if high_contrast_check != null:
			high_contrast_check.button_pressed = SaveManager.current_settings.get("high_contrast", false)

func _on_master_changed(val: float) -> void:
	if master_label != null: master_label.text = "Master: %d%%" % int(val)
	var norm := val / 100.0
	if SaveManager != null:
		SaveManager.current_settings["master_volume"] = norm
		SaveManager.apply_settings()

func _on_music_changed(val: float) -> void:
	if music_label != null: music_label.text = "Music: %d%%" % int(val)
	var norm := val / 100.0
	if SaveManager != null:
		SaveManager.current_settings["music_volume"] = norm
		SaveManager.apply_settings()

func _on_sfx_changed(val: float) -> void:
	if sfx_label != null: sfx_label.text = "SFX: %d%%" % int(val)
	var norm := val / 100.0
	if SaveManager != null:
		SaveManager.current_settings["sfx_volume"] = norm
		SaveManager.apply_settings()

func _on_tutorial_toggled(val: bool) -> void:
	if SaveManager != null:
		SaveManager.current_settings["show_tutorials"] = val

func _on_voiceover_toggled(val: bool) -> void:
	if SaveManager != null:
		SaveManager.current_settings["voiceover_enabled"] = val
		SaveManager.apply_settings()
	if not val and AudioManager != null and AudioManager.has_method("stop_voiceover"):
		AudioManager.stop_voiceover()

func _on_large_text_toggled(val: bool) -> void:
	if SaveManager != null:
		SaveManager.current_settings["large_text"] = val
		SaveManager.apply_settings()

func _on_instant_dialogue_toggled(val: bool) -> void:
	if SaveManager != null:
		SaveManager.current_settings["instant_dialogue"] = val
		SaveManager.apply_settings()

func _on_high_contrast_toggled(val: bool) -> void:
	if SaveManager != null:
		SaveManager.current_settings["high_contrast"] = val
		SaveManager.apply_settings()

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

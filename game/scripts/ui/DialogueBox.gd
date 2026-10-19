class_name DialogueBox
extends Control

@onready var panel: Panel = $Panel
@onready var portrait: TextureRect = $Panel/HBox/Portrait
@onready var speaker_label: Label = $Panel/HBox/ContentVBox/SpeakerLabel if has_node("Panel/HBox/ContentVBox/SpeakerLabel") else $Panel/HBox/VBox/SpeakerLabel
@onready var text_label: RichTextLabel = $Panel/HBox/ContentVBox/TextLabel if has_node("Panel/HBox/ContentVBox/TextLabel") else $Panel/HBox/VBox/TextLabel
@onready var next_btn: Button = $Panel/HBox/ContentVBox/ActionHBox/NextBtn if has_node("Panel/HBox/ContentVBox/ActionHBox/NextBtn") else $Panel/NextBtn
@onready var choices_container: VBoxContainer = $Panel/HBox/ContentVBox/ChoicesContainer if has_node("Panel/HBox/ContentVBox/ChoicesContainer") else $Panel/ChoicesContainer

var full_text: String = ""
var is_typing: bool = false
var char_index: int = 0
var typing_speed: float = 0.025
var type_timer: float = 0.0

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	if panel != null:
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		var style := GamePalette.create_panel_style(GamePalette.COLOR_SAND, GamePalette.COLOR_WARM_GOLD, 10, 3)
		panel.add_theme_stylebox_override("panel", style)
		
	_apply_typography()
		
	if next_btn != null:
		GamePalette.apply_button_theme(next_btn, GamePalette.COLOR_TERRACOTTA, GamePalette.FONT_SIZE_BUTTON)
		next_btn.pressed.connect(_on_next_pressed)
		
	if DialogueManager != null:
		DialogueManager.dialogue_started.connect(_on_dialogue_started)
		DialogueManager.dialogue_node_reached.connect(_on_dialogue_node_reached)
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
		
	if SaveManager != null and SaveManager.has_signal("settings_changed"):
		SaveManager.settings_changed.connect(_apply_typography)

func _apply_typography() -> void:
	if speaker_label != null:
		speaker_label.add_theme_color_override("font_color", GamePalette.COLOR_DEEP_EARTH)
		speaker_label.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_H2))
		
	if text_label != null:
		text_label.add_theme_color_override("default_color", GamePalette.COLOR_CHARCOAL)
		text_label.add_theme_font_size_override("normal_font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_DIALOGUE))
		
	if next_btn != null:
		GamePalette.apply_button_theme(next_btn, GamePalette.COLOR_TERRACOTTA, GamePalette.FONT_SIZE_BUTTON)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.is_pressed():
			_on_box_clicked()

func _on_box_clicked() -> void:
	if choices_container != null and choices_container.visible and choices_container.get_child_count() > 0:
		return
	if is_typing:
		_finish_typing()
	else:
		_on_next_pressed()

func _process(delta: float) -> void:
	if is_typing:
		type_timer += delta
		if type_timer >= typing_speed:
			type_timer = 0.0
			char_index += 1
			text_label.visible_characters = char_index
			if char_index % 3 == 0 and AudioManager != null:
				AudioManager.play_sfx("sfx_dialogue_blip", randf_range(0.95, 1.05))
			if char_index >= full_text.length():
				_finish_typing()

func _on_dialogue_started(_dialogue_id: String) -> void:
	visible = true

func _adjust_panel_for_choices(has_choices: bool) -> void:
	if panel == null:
		return
	if has_choices:
		panel.offset_top = -330.0
		panel.offset_bottom = -16.0
	else:
		panel.offset_top = -240.0
		panel.offset_bottom = -16.0

func _on_dialogue_node_reached(node_data: Dictionary) -> void:
	visible = true
	speaker_label.text = node_data.get("speaker", "...")
	full_text = node_data.get("text", "")
	
	var port_path: String = node_data.get("portrait", "")
	if port_path != "" and ResourceLoader.exists(port_path):
		portrait.texture = load(port_path)
		portrait.visible = true
	else:
		portrait.visible = false
		
	# Clear choices
	for c in choices_container.get_children():
		c.queue_free()
	choices_container.visible = false
	next_btn.visible = true
	
	# Start typewriter or display instantly based on accessibility settings
	text_label.text = full_text
	var instant: bool = false
	if SaveManager != null:
		instant = SaveManager.current_settings.get("instant_dialogue", false)
		
	if instant:
		text_label.visible_characters = -1
		is_typing = false
	else:
		text_label.visible_characters = 0
		char_index = 0
		type_timer = 0.0
		is_typing = true
		
	# Play accessibility Voiceover / TTS
	if AudioManager != null and AudioManager.has_method("speak_text"):
		AudioManager.speak_text(full_text, speaker_label.text)
	
	# Setup choices if any
	var choices: Array = node_data.get("choices", [])
	if not choices.is_empty():
		next_btn.visible = false
		_setup_choices(choices)
		# When choices are present, display dialogue text immediately so player can read speaker text
		text_label.visible_characters = -1
		is_typing = false
	else:
		_adjust_panel_for_choices(false)

func _setup_choices(choices: Array) -> void:
	choices_container.visible = true
	_adjust_panel_for_choices(true)
	for i in range(choices.size()):
		var choice_data: Dictionary = choices[i]
		var btn := Button.new()
		var choice_text: String = choice_data.get("text", "...")
		btn.text = "◆ " + choice_text if not choice_text.begins_with("◆") else choice_text
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 42)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Compact choice style with sleek margins
		var normal_box := GamePalette.create_button_style(GamePalette.COLOR_TERRACOTTA, GamePalette.COLOR_WARM_GOLD, 6)
		normal_box.content_margin_top = 8
		normal_box.content_margin_bottom = 8
		normal_box.content_margin_left = 14
		normal_box.content_margin_right = 14
		
		var hover_box := GamePalette.create_button_style(GamePalette.COLOR_TERRACOTTA.lightened(0.15), GamePalette.COLOR_IVORY, 6)
		hover_box.content_margin_top = 8
		hover_box.content_margin_bottom = 8
		hover_box.content_margin_left = 14
		hover_box.content_margin_right = 14
		
		btn.add_theme_stylebox_override("normal", normal_box)
		btn.add_theme_stylebox_override("hover", hover_box)
		btn.add_theme_stylebox_override("pressed", hover_box)
		btn.add_theme_stylebox_override("focus", hover_box)
		btn.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)
		btn.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BODY))
		
		var choice_idx := i
		btn.pressed.connect(func():
			if AudioManager != null:
				AudioManager.play_sfx("sfx_click")
				if AudioManager.has_method("stop_voiceover"):
					AudioManager.stop_voiceover()
			DialogueManager.select_choice(choice_idx)
		)
		choices_container.add_child(btn)

func _finish_typing() -> void:
	is_typing = false
	text_label.visible_characters = -1

func _on_next_pressed() -> void:
	if is_typing:
		_finish_typing()
	else:
		if AudioManager != null:
			AudioManager.play_sfx("sfx_click")
			if AudioManager.has_method("stop_voiceover"):
				AudioManager.stop_voiceover()
		DialogueManager.next_line()

func _on_dialogue_ended(_dialogue_id: String) -> void:
	visible = false
	is_typing = false
	_adjust_panel_for_choices(false)
	if AudioManager != null and AudioManager.has_method("stop_voiceover"):
		AudioManager.stop_voiceover()

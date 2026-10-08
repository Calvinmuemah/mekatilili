class_name DialogueBox
extends Control

@onready var panel: Panel = $Panel
@onready var portrait: TextureRect = $Panel/HBox/Portrait
@onready var speaker_label: Label = $Panel/HBox/VBox/SpeakerLabel
@onready var text_label: RichTextLabel = $Panel/HBox/VBox/TextLabel
@onready var next_btn: Button = $Panel/NextBtn
@onready var choices_container: VBoxContainer = $Panel/ChoicesContainer

var full_text: String = ""
var is_typing: bool = false
var char_index: int = 0
var typing_speed: float = 0.025
var type_timer: float = 0.0

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if panel != null:
		var style := GamePalette.create_panel_style(GamePalette.COLOR_SAND, GamePalette.COLOR_WARM_GOLD, 10, 3)
		panel.add_theme_stylebox_override("panel", style)
		
	if speaker_label != null:
		speaker_label.add_theme_color_override("font_color", GamePalette.COLOR_DEEP_EARTH)
		speaker_label.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_H2)
		
	if text_label != null:
		text_label.add_theme_color_override("default_color", GamePalette.COLOR_CHARCOAL)
		text_label.add_theme_font_size_override("normal_font_size", GamePalette.FONT_SIZE_DIALOGUE)
		
	if next_btn != null:
		GamePalette.apply_button_theme(next_btn, GamePalette.COLOR_TERRACOTTA)
		next_btn.pressed.connect(_on_next_pressed)
		
	if DialogueManager != null:
		DialogueManager.dialogue_started.connect(_on_dialogue_started)
		DialogueManager.dialogue_node_reached.connect(_on_dialogue_node_reached)
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

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
	
	# Start typewriter
	text_label.text = full_text
	text_label.visible_characters = 0
	char_index = 0
	type_timer = 0.0
	is_typing = true
	
	# Setup choices if any
	var choices: Array = node_data.get("choices", [])
	if not choices.is_empty():
		next_btn.visible = false
		_setup_choices(choices)

func _setup_choices(choices: Array) -> void:
	choices_container.visible = true
	for i in range(choices.size()):
		var choice_data: Dictionary = choices[i]
		var btn := Button.new()
		btn.text = choice_data.get("text", "...")
		GamePalette.apply_button_theme(btn, GamePalette.COLOR_TERRACOTTA)
		var choice_idx := i
		btn.pressed.connect(func():
			if AudioManager != null:
				AudioManager.play_sfx("sfx_click")
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
		DialogueManager.next_line()

func _on_dialogue_ended(_dialogue_id: String) -> void:
	visible = false
	is_typing = false

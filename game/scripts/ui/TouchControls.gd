class_name TouchControls
extends Control

@onready var joystick_base: Control = $JoystickBase
@onready var joystick_knob: Sprite2D = $JoystickBase/Knob
@onready var action_btn: Button = $ActionBtn

var touch_index: int = -1
var joystick_center: Vector2 = Vector2(80, 80)
var max_radius: float = 50.0
var current_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style_touch_buttons()
	if action_btn != null:
		action_btn.pressed.connect(_on_action_pressed)
	if joystick_base != null:
		joystick_base.gui_input.connect(_on_joystick_gui_input)
		
	if SaveManager != null and SaveManager.has_signal("settings_changed"):
		SaveManager.settings_changed.connect(_style_touch_buttons)

func _style_touch_buttons() -> void:
	if action_btn != null:
		var sb_norm := GamePalette.create_button_style(Color(0.72, 0.36, 0.22, 0.82), GamePalette.COLOR_WARM_GOLD, 10)
		var sb_press := GamePalette.create_button_style(Color(0.85, 0.45, 0.28, 0.95), GamePalette.COLOR_WARM_GOLD, 10)
		action_btn.add_theme_stylebox_override("normal", sb_norm)
		action_btn.add_theme_stylebox_override("hover", sb_press)
		action_btn.add_theme_stylebox_override("pressed", sb_press)
		action_btn.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)
		action_btn.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BUTTON + 2))

func _on_joystick_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			_handle_joystick_motion(event.position)
			accept_event()
		elif not event.pressed and event.index == touch_index:
			_reset_joystick()
			accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and touch_index == -1:
			touch_index = 999
			_handle_joystick_motion(event.position)
			accept_event()
		elif not event.pressed and touch_index == 999:
			_reset_joystick()
			accept_event()

func _input(event: InputEvent) -> void:
	if touch_index == -1:
		return
		
	if event is InputEventScreenDrag and event.index == touch_index:
		var local_pos := joystick_base.get_local_mouse_position()
		_handle_joystick_motion(local_pos)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and not event.pressed and event.index == touch_index:
		_reset_joystick()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and touch_index == 999:
		var local_pos := joystick_base.get_local_mouse_position()
		_handle_joystick_motion(local_pos)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT and touch_index == 999:
		_reset_joystick()
		get_viewport().set_input_as_handled()

func _handle_joystick_motion(local_pos: Vector2) -> void:
	var diff := local_pos - joystick_center
	if diff.length() > max_radius:
		diff = diff.normalized() * max_radius
	joystick_knob.position = joystick_center + diff
	current_vector = diff / max_radius
	_update_player_joystick(current_vector)

func _reset_joystick() -> void:
	touch_index = -1
	joystick_knob.position = joystick_center
	current_vector = Vector2.ZERO
	_update_player_joystick(Vector2.ZERO)

func _update_player_joystick(vec: Vector2) -> void:
	if GameManager != null and GameManager.player_node != null and is_instance_valid(GameManager.player_node):
		if GameManager.player_node.has_method("_get_movement_vector"):
			GameManager.player_node.joystick_direction = vec

func _on_action_pressed() -> void:
	if GameManager != null and GameManager.player_node != null and is_instance_valid(GameManager.player_node):
		GameManager.player_node.trigger_interaction()

func _on_journal_pressed() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("toggle_journal"):
		hud.toggle_journal()

func _on_pause_pressed() -> void:
	if GameManager != null:
		GameManager.toggle_pause()

class_name TouchControls
extends Control

@onready var joystick_base: Control = $JoystickBase
@onready var joystick_knob: Sprite2D = $JoystickBase/Knob
@onready var action_btn: Button = $ActionBtn
@onready var journal_btn: Button = $TopButtons/JournalBtn
@onready var pause_btn: Button = $TopButtons/PauseBtn

var touch_index: int = -1
var joystick_center: Vector2 = Vector2(80, 80)
var max_radius: float = 50.0
var current_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	if action_btn != null:
		GamePalette.apply_button_theme(action_btn, GamePalette.COLOR_TERRACOTTA)
		action_btn.pressed.connect(_on_action_pressed)
	if journal_btn != null:
		GamePalette.apply_button_theme(journal_btn, GamePalette.COLOR_FOREST_GREEN)
		journal_btn.pressed.connect(_on_journal_pressed)
	if pause_btn != null:
		GamePalette.apply_button_theme(pause_btn, GamePalette.COLOR_DEEP_EARTH)
		pause_btn.pressed.connect(_on_pause_pressed)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			var local_pos := joystick_base.get_local_mouse_position()
			if local_pos.distance_to(joystick_center) <= max_radius * 1.5:
				touch_index = event.index
				_handle_joystick_motion(local_pos)
		elif not event.pressed and event.index == touch_index:
			_reset_joystick()
	elif event is InputEventScreenDrag and event.index == touch_index:
		var local_pos := joystick_base.get_local_mouse_position()
		_handle_joystick_motion(local_pos)

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

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

func set_prompt(msg: String) -> void:
	if action_btn == null:
		return
	var clean_msg := msg
	clean_msg = clean_msg.replace("[E / TAP]", "")
	clean_msg = clean_msg.replace("[E/TAP]", "")
	clean_msg = clean_msg.replace("[E /", "")
	clean_msg = clean_msg.replace("[E]", "")
	clean_msg = clean_msg.replace("[TAP]", "")
	clean_msg = clean_msg.replace("TAP]", "")
	clean_msg = clean_msg.replace("TAP", "")
	clean_msg = clean_msg.strip_edges()
	
	if clean_msg == "":
		action_btn.text = "✦ ACTION"
		action_btn.modulate = Color(1.0, 1.0, 1.0, 0.65)
	else:
		action_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
		var lower := clean_msg.to_lower()
		if "tend" in lower or "crop" in lower or "cassava" in lower or "harvest" in lower or "shamba" in lower:
			action_btn.text = "🌿 TEND CROP"
		elif "water" in lower or "spring" in lower or "replenish" in lower or "calabash" in lower:
			action_btn.text = "💧 REPLENISH"
		elif "herb" in lower or "forage" in lower or "medicine" in lower or "medicinal" in lower:
			action_btn.text = "🌿 FORAGE"
		elif "scout" in lower or "slip" in lower or "evade" in lower:
			action_btn.text = "👣 EVADE"
		elif "reunite" in lower or "reunion" in lower:
			action_btn.text = "🔥 REUNITE"
		elif "whisper" in lower:
			action_btn.text = "💬 WHISPER"
		elif "key" in lower or "seize" in lower or "unlock" in lower:
			action_btn.text = "🗝️ UNLOCK"
		elif "escape" in lower:
			action_btn.text = "🚪 ESCAPE"
		elif "plan" in lower:
			action_btn.text = "📜 PLAN"
		elif "confront" in lower:
			action_btn.text = "⚡ CONFRONT"
		elif "talk" in lower or "speak" in lower or "elder" in lower or "nyevu" in lower or "fondo" in lower or "wanje" in lower or "charo" in lower or "champion" in lower:
			action_btn.text = "💬 TALK"
		elif "examine" in lower or "inspect" in lower or "collect" in lower or "notice" in lower:
			action_btn.text = "🔍 EXAMINE"
		elif "gather" in lower or "fire" in lower or "assembly" in lower or "address" in lower or "oath" in lower:
			action_btn.text = "🔥 ADDRESS" if "address" in lower else "🔥 GATHER"
		elif "hen" in lower or "chick" in lower or "release" in lower:
			action_btn.text = "🐔 RELEASE"
		elif "enter" in lower or "march" in lower or "gate" in lower:
			action_btn.text = "🚪 ENTER" if "enter" in lower else "🚶 MARCH"
		else:
			var words := clean_msg.strip_edges().split(" ")
			if words.size() == 1:
				action_btn.text = "✦ " + words[0].to_upper()
			elif words.size() >= 2:
				var candidate := words[0].to_upper() + " " + words[1].to_upper()
				if candidate.length() <= 13:
					action_btn.text = "✦ " + candidate
				else:
					action_btn.text = "✦ " + words[0].to_upper()
			else:
				action_btn.text = "✦ ACTION"

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

func _get_active_player() -> Node2D:
	if GameManager != null and GameManager.player_node != null and is_instance_valid(GameManager.player_node):
		return GameManager.player_node
	var p: Node = get_tree().get_first_node_in_group("player")
	if p != null and is_instance_valid(p) and p is Node2D:
		if GameManager != null:
			GameManager.player_node = p as Node2D
		return p as Node2D
	return null

func _update_player_joystick(vec: Vector2) -> void:
	var player := _get_active_player()
	if player != null and player.has_method("_get_movement_vector"):
		player.joystick_direction = vec

func _on_action_pressed() -> void:
	var player := _get_active_player()
	if player != null and player.has_method("trigger_interaction"):
		player.trigger_interaction()

func _on_journal_pressed() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("toggle_journal"):
		hud.toggle_journal()

func _on_pause_pressed() -> void:
	if GameManager != null:
		GameManager.toggle_pause()

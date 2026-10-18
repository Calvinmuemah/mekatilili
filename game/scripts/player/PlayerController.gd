class_name PlayerController
extends CharacterBody2D

@export var move_speed: float = 160.0

var can_move: bool = true
var joystick_direction: Vector2 = Vector2.ZERO
var current_facing: String = "down"
var is_moving: bool = false
var footstep_timer: float = 0.0

# Interaction detection
var nearby_interactables: Array[Interactable] = []
var active_interactable: Interactable = null

# Child nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_detector: Area2D = $InteractionDetector

# Animation frames
var frame_timer: float = 0.0
var current_frame_idx: int = 0
const ANIM_FRAME_TIME: float = 0.15

func _ready() -> void:
	if GameManager != null:
		GameManager.player_node = self
		if GameManager.saved_player_position != Vector2.ZERO:
			global_position = GameManager.saved_player_position
			GameManager.saved_player_position = Vector2.ZERO
			
	if DialogueManager != null:
		DialogueManager.dialogue_started.connect(func(_id): set_can_move(false))
		DialogueManager.dialogue_ended.connect(func(_id): set_can_move(true))
		
	if interaction_detector != null:
		interaction_detector.area_entered.connect(_on_interaction_area_entered)
		interaction_detector.area_exited.connect(_on_interaction_area_exited)

var nav_target_position: Vector2 = Vector2.ZERO
var is_navigating: bool = false

func navigate_to(target_pos: Vector2) -> void:
	nav_target_position = target_pos
	is_navigating = true

func cancel_navigation() -> void:
	is_navigating = false

func set_can_move(val: bool) -> void:
	can_move = val
	if not val:
		velocity = Vector2.ZERO
		is_moving = false
		is_navigating = false
		_update_sprite_frame(0)

func _physics_process(delta: float) -> void:
	if not can_move or (DialogueManager != null and DialogueManager.is_active):
		velocity = Vector2.ZERO
		is_navigating = false
		_update_sprite_frame(0)
		move_and_slide()
		return
		
	var input_vec := _get_movement_vector()
	if input_vec.length_squared() > 0.01:
		input_vec = input_vec.normalized()
		velocity = input_vec * move_speed
		is_moving = true
		_update_facing(input_vec)
		
		# Animate
		frame_timer += delta
		if frame_timer >= ANIM_FRAME_TIME:
			frame_timer = 0.0
			current_frame_idx = (current_frame_idx + 1) % 4
			_update_sprite_frame(current_frame_idx)
			
		# Footsteps
		footstep_timer += delta
		if footstep_timer >= 0.35:
			footstep_timer = 0.0
			if AudioManager != null:
				AudioManager.play_sfx("sfx_footstep", randf_range(0.9, 1.1))
	else:
		velocity = Vector2.ZERO
		is_moving = false
		current_frame_idx = 0
		frame_timer = 0.0
		_update_sprite_frame(0)
		
	move_and_slide()
	_update_active_interactable()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		trigger_interaction()

func _unhandled_input(event: InputEvent) -> void:
	if not can_move or (DialogueManager != null and DialogueManager.is_active):
		return
	if event is InputEventScreenTouch and event.pressed:
		var world_pos: Vector2 = get_canvas_transform().affine_inverse() * event.position
		navigate_to(world_pos)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_pos: Vector2 = get_canvas_transform().affine_inverse() * event.position
		navigate_to(world_pos)

func trigger_interaction() -> void:
	if not can_move and (DialogueManager == null or not DialogueManager.is_active):
		return
	if DialogueManager != null and DialogueManager.is_active:
		DialogueManager.next_line()
		return
	if active_interactable != null and is_instance_valid(active_interactable):
		active_interactable.interact(self)

func _get_movement_vector() -> Vector2:
	if joystick_direction.length_squared() > 0.05:
		is_navigating = false
		return joystick_direction
		
	var vec := Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		vec.x -= 1.0
	if Input.is_action_pressed("move_right"):
		vec.x += 1.0
	if Input.is_action_pressed("move_up"):
		vec.y -= 1.0
	if Input.is_action_pressed("move_down"):
		vec.y += 1.0
		
	if vec.length_squared() > 0.01:
		is_navigating = false
		return vec

	if is_navigating:
		var diff := nav_target_position - global_position
		if diff.length() < 16.0:
			is_navigating = false
			return Vector2.ZERO
		return diff.normalized()

	return Vector2.ZERO

func _update_facing(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		current_facing = "right" if dir.x > 0 else "left"
	else:
		current_facing = "down" if dir.y > 0 else "up"

func _update_sprite_frame(frame_num: int) -> void:
	if sprite == null:
		return
	# Sheet is 4 columns (frames 0-3), 4 rows (0: Down, 1: Up, 2: Left, 3: Right)
	var row := 0
	match current_facing:
		"down": row = 0
		"up": row = 1
		"left": row = 2
		"right": row = 3
	sprite.frame = row * 4 + frame_num

func _on_interaction_area_entered(area: Area2D) -> void:
	if area is Interactable:
		if not nearby_interactables.has(area):
			nearby_interactables.append(area)
		_update_active_interactable()

func _on_interaction_area_exited(area: Area2D) -> void:
	if area is Interactable:
		nearby_interactables.erase(area)
		if active_interactable == area:
			area.set_focused(false)
			active_interactable = null
		_update_active_interactable()

func _update_active_interactable() -> void:
	# Clean up any freed objects
	nearby_interactables = nearby_interactables.filter(func(item): return is_instance_valid(item) and item.is_interactable)
	
	if nearby_interactables.is_empty():
		if active_interactable != null:
			active_interactable.set_focused(false)
			active_interactable = null
		_notify_hud_interaction("")
		return
		
	# Find closest
	var closest: Interactable = null
	var min_dist: float = 999999.0
	for item in nearby_interactables:
		var dist := global_position.distance_to(item.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = item
			
	if active_interactable != closest:
		if active_interactable != null:
			active_interactable.set_focused(false)
		active_interactable = closest
		if active_interactable != null:
			active_interactable.set_focused(true)
			_notify_hud_interaction(active_interactable.prompt_message)

func _notify_hud_interaction(prompt_text: String) -> void:
	# Send to in-game HUD prompt if present
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("set_interaction_prompt"):
		hud.set_interaction_prompt(prompt_text)

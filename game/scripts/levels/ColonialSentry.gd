class_name ColonialSentry
extends CharacterBody2D

@export var patrol_points: Array[Vector2] = []
@export var patrol_speed: float = 40.0
@export var chase_speed: float = 115.0
@export var detection_radius: float = 180.0

var current_patrol_idx: int = 0
var is_chasing: bool = false
var alert_cooldown: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var vision_area: Area2D = $VisionArea
@onready var catch_area: Area2D = $CatchArea
@onready var alert_label: Label = $AlertLabel

func _ready() -> void:
	if alert_label != null:
		alert_label.visible = false
		alert_label.add_theme_color_override("font_color", GamePalette.COLOR_TERRACOTTA)
	
	if catch_area != null:
		catch_area.body_entered.connect(_on_catch_body_entered)

func set_chase_mode(active: bool) -> void:
	is_chasing = active
	if alert_label != null:
		alert_label.visible = active
	if active and AudioManager != null:
		AudioManager.play_sfx("sfx_whistle", 1.0)

func _physics_process(delta: float) -> void:
	if alert_cooldown > 0.0:
		alert_cooldown -= delta
		
	var player = GameManager.player_node if GameManager != null else null
	if not is_instance_valid(player):
		return
		
	var dist_to_player := global_position.distance_to(player.global_position)
	
	# If global chase active or player close during confrontation
	var global_chase := StoryManager != null and StoryManager.has_flag("chase_active")
	if global_chase and not is_chasing:
		set_chase_mode(true)
		
	if is_chasing:
		var dir: Vector2 = (player.global_position - global_position).normalized()
		velocity = dir * chase_speed
		move_and_slide()
		_update_facing(dir)
	elif not patrol_points.is_empty():
		var target := patrol_points[current_patrol_idx]
		if global_position.distance_to(target) < 10.0:
			current_patrol_idx = (current_patrol_idx + 1) % patrol_points.size()
		var dir: Vector2 = (target - global_position).normalized()
		velocity = dir * patrol_speed
		move_and_slide()
		_update_facing(dir)
	else:
		velocity = Vector2.ZERO

func _update_facing(dir: Vector2) -> void:
	if sprite == null:
		return
	if abs(dir.x) > abs(dir.y):
		sprite.frame = 4 if dir.x < 0 else 8 # Left or Right row
	else:
		sprite.frame = 12 if dir.y < 0 else 0 # Up or Down row

func _on_catch_body_entered(body: Node2D) -> void:
	if body is PlayerController and alert_cooldown <= 0.0:
		alert_cooldown = 2.0
		if AudioManager != null:
			AudioManager.play_sfx("sfx_whistle", 1.2)
		# Push player back slightly to maintain exciting pursuit gameplay
		var push_dir := (body.global_position - global_position).normalized()
		body.global_position += push_dir * 45.0
		
		var hud := get_tree().get_first_node_in_group("hud")
		if hud != null and hud.has_method("show_collectible_banner"):
			hud.show_collectible_banner("Colonial Sentry Alert!", "The askari are on your heels! Evade their line of sight and sprint for the South Exit Gate!")

class_name Interactable
extends Area2D

signal interacted(interactor: Node2D)
signal focused_changed(is_focused: bool)

@export var prompt_message: String = "Interact"
@export var is_interactable: bool = true
@export var marker_type: String = "talk" # "talk" or "quest"
@export var prompt_offset: Vector2 = Vector2(0, -46)

var is_focused: bool = false
var indicator_sprite: Sprite2D = null

func _ready() -> void:
	collision_layer = 16 # Layer 5: Interactables
	collision_mask = 0
	_setup_indicator()

func _setup_indicator() -> void:
	indicator_sprite = Sprite2D.new()
	var marker_path := "res://assets/icons/quest_marker.png" if marker_type == "quest" else "res://assets/icons/talk_marker.png"
	if ResourceLoader.exists(marker_path):
		indicator_sprite.texture = load(marker_path)
		# 64x64 marker at 0.85 scale provides a crisp, highly readable ~54px marker for players of all ages
		indicator_sprite.scale = Vector2(0.85, 0.85)
	indicator_sprite.position = prompt_offset
	indicator_sprite.visible = false
	indicator_sprite.z_index = 10
	add_child(indicator_sprite)

func set_focused(focused: bool) -> void:
	if not is_interactable:
		focused = false
	is_focused = focused
	if indicator_sprite != null:
		indicator_sprite.visible = focused
		if focused:
			# Gentle high-visibility bounce tween
			var tween := create_tween().set_loops()
			tween.tween_property(indicator_sprite, "position:y", prompt_offset.y - 8.0, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(indicator_sprite, "position:y", prompt_offset.y, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	focused_changed.emit(focused)

func interact(interactor: Node2D) -> void:
	if not is_interactable:
		return
	interacted.emit(interactor)

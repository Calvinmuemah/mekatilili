class_name NPCController
extends CharacterBody2D

@export var npc_name: String = "Elder"
@export var dialogue_id: String = ""
@export var portrait_path: String = ""
@export var sprite_sheet: Texture2D
@export var facing_direction: String = "down"

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	if sprite != null and sprite_sheet != null:
		sprite.texture = sprite_sheet
	_update_facing(facing_direction)
	
	if interactable != null:
		interactable.prompt_message = "Talk to " + npc_name
		interactable.interacted.connect(_on_interacted)

func _update_facing(direct: String) -> void:
	facing_direction = direct
	if sprite == null:
		return
	var row := 0
	match direct:
		"down": row = 0
		"up": row = 1
		"left": row = 2
		"right": row = 3
	sprite.frame = row * 4 # Default idle frame for that direction

func _on_interacted(interactor: Node2D) -> void:
	# Face the player
	if interactor != null:
		var dir := (interactor.global_position - global_position).normalized()
		if abs(dir.x) > abs(dir.y):
			_update_facing("right" if dir.x > 0 else "left")
		else:
			_update_facing("down" if dir.y > 0 else "up")
			
	if dialogue_id != "" and DialogueManager != null:
		DialogueManager.start_dialogue(dialogue_id)

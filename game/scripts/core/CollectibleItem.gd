class_name CollectibleItem
extends Node2D

@export var item_id: String = "calabash_palm"
@export var item_name: String = "Traditional Palm Calabash"
@export var item_description: String = "A dried gourd used for water and mnazi."
@export var historical_note: String = "Central to Giriama community gatherings."
@export var item_icon: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	if sprite != null and item_icon != null:
		sprite.texture = item_icon
		
	# Check if already collected in StoryManager
	if StoryManager != null:
		for c in StoryManager.collectibles:
			if c.get("id", "") == item_id:
				queue_free()
				return
				
	if interactable != null:
		interactable.prompt_message = "Examine " + item_name
		interactable.interacted.connect(_on_interacted)

func _on_interacted(_interactor: Node2D) -> void:
	if StoryManager != null:
		var path_str := ""
		if item_icon != null:
			path_str = item_icon.resource_path
		StoryManager.add_collectible(item_id, item_name, item_description, path_str, historical_note)
		
	# Notify HUD
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_collectible_banner"):
		hud.show_collectible_banner(item_name, item_description)
		
	# Disable and fade out
	interactable.is_interactable = false
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

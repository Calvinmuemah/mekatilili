class_name ShambaCrop
extends Node2D

@export var crop_name: String = "Cassava Crop"
var is_harvested: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	if interactable != null:
		interactable.prompt_message = "Tend " + crop_name
		interactable.interacted.connect(_on_interacted)

func _on_interacted(_interactor: Node2D) -> void:
	if is_harvested:
		return
	is_harvested = true
	interactable.is_interactable = false
	
	if AudioManager != null:
		AudioManager.play_sfx("sfx_item_collect")
		
	# Complete quest objective 1 ("inspect_crops")
	if QuestManager != null:
		QuestManager.complete_objective("quest_chapter_1", 1)
		
	if StoryManager != null:
		StoryManager.add_community_support(15)
		StoryManager.add_journal_entry(
			"story",
			"Tending the Shamba",
			"Mekatilili inspected the village cassava fields. The harvest belongs to the Giriama people, not foreign colonial taxation."
		)
		
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_collectible_banner"):
		hud.show_collectible_banner("Cassava Harvested", "Traditional food stores replenished for the community.")
		
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(0.7, 0.6, 0.4), 0.4)

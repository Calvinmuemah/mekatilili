class_name CouncilFire
extends Node2D

@onready var interactable: Interactable = $Interactable
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if interactable != null:
		interactable.prompt_message = "Gather the Community"
		interactable.interacted.connect(_on_interacted)

func _on_interacted(_interactor: Node2D) -> void:
	var lvl := GameManager.current_level if GameManager != null else 1
	if lvl >= 2:
		var hud := get_tree().get_first_node_in_group("hud")
		if hud != null and hud.has_method("show_collectible_banner"):
			hud.show_collectible_banner(
				"Council Fire",
				"The fire burns with the sacred vows sworn during Chapter 1. Proceed with the Chapter 2 resistance circuit."
			)
		return

	var q := QuestManager.get_active_quest() if QuestManager != null else {}
	var objs: Array = q.get("objectives", [])
	
	var prior_complete := true
	if objs.size() >= 5:
		for i in range(4):
			if not objs[i].get("completed", false):
				prior_complete = false
				break
	else:
		var current_idx: int = q.get("current_objective_index", 0)
		prior_complete = current_idx >= 4
	
	# If prior objectives not complete, give hint
	if not prior_complete:
		var hud := get_tree().get_first_node_in_group("hud")
		if hud != null and hud.has_method("show_collectible_banner"):
			hud.show_collectible_banner(
				"Council Fire",
				"The fire awaits. Consult Villager Nyevu, tend the Shamba, speak to Mzee Fondo, and find Wanje first."
			)
		return
		
	# Complete final objective of Chapter 1
	if QuestManager != null:
		QuestManager.complete_objective("quest_chapter_1", 4)
		
	if StoryManager != null:
		StoryManager.add_community_support(30)
		StoryManager.add_journal_entry(
			"story",
			"The Gathering at Ulungu",
			"Mekatilili wa Menza and Wanje wa Mwadorikola addressed the gathering at the council fire. The village pledged total solidarity against colonial forced recruitment."
		)
		
	interactable.is_interactable = false
	
	# Complete Chapter 1 and transition to Chapter Complete Screen!
	if GameManager != null:
		GameManager.current_chapter = 2
		GameManager.current_level = 2
		GameManager.complete_current_chapter()


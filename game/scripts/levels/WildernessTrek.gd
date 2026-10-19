class_name WildernessTrek
extends Node2D

@onready var player: PlayerController = $Player
@onready var hud: HUD = $HUD
@onready var chapter_intro_panel: Panel = $HUD/ChapterIntroPanel
@onready var chapter_intro_title: Label = $HUD/ChapterIntroPanel/VBox/Title
@onready var chapter_intro_sub: Label = $HUD/ChapterIntroPanel/VBox/Subtitle

@onready var water_interactable: Interactable = $WaterSpring/Interactable
@onready var herb_interactable: Interactable = $HerbPatch/Interactable
@onready var scout_interactable: Interactable = $ScoutPost/Interactable
@onready var reunion_interactable: Interactable = $KayaReunion/Interactable

var water_collected: bool = false
var herbs_collected: bool = false
var scout_evaded: bool = false

func _ready() -> void:
	if GameManager != null:
		GameManager.set_game_state(GameManager.GameState.IN_GAME)
		GameManager.current_level = 11
		GameManager.current_scene_path = scene_file_path

	if AudioManager != null:
		AudioManager.play_ambient("res://assets/audio/ambient_coastal_loop.wav")
		AudioManager.play_music("res://assets/audio/music_intro_loop.wav")

	_setup_camera_limits()
	_show_intro_banner("CHAPTER III: LEVEL 11", "The Thousand-Kilometer Walk Home")

	if QuestManager != null:
		QuestManager.start_quest("quest_level_11")

	if StoryManager != null:
		StoryManager.set_community_support(10) # Reset endurance meter for trek

	if SaveManager != null:
		SaveManager.save_game({"chapter": 3, "level": 11, "scene": scene_file_path})

	# Connect interactables
	if water_interactable != null:
		water_interactable.prompt_message = "Replenish Calabash at Spring"
		water_interactable.interacted.connect(_on_water_interacted)

	if herb_interactable != null:
		herb_interactable.prompt_message = "Forage Rift Valley Herbs"
		herb_interactable.interacted.connect(_on_herb_interacted)

	if scout_interactable != null:
		scout_interactable.prompt_message = "Slip Past Railway Scouts"
		scout_interactable.interacted.connect(_on_scout_interacted)

	if reunion_interactable != null:
		reunion_interactable.prompt_message = "Reunite with Kaya Elders"
		reunion_interactable.interacted.connect(_on_reunion_interacted)

	if DialogueManager != null:
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _setup_camera_limits() -> void:
	if player != null:
		var cam: Camera2D = player.get_node_or_null("Camera2D")
		if cam != null:
			cam.limit_left = 0
			cam.limit_top = 0
			cam.limit_right = 2100
			cam.limit_bottom = 900

func _show_intro_banner(title: String, subtitle: String) -> void:
	if chapter_intro_panel != null:
		var style := GamePalette.create_panel_style(GamePalette.COLOR_DEEP_EARTH, GamePalette.COLOR_WARM_GOLD, 12, 3)
		chapter_intro_panel.add_theme_stylebox_override("panel", style)
		chapter_intro_title.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
		chapter_intro_title.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_H1)
		chapter_intro_title.text = title
		chapter_intro_sub.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)
		chapter_intro_sub.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_BODY)
		chapter_intro_sub.text = subtitle

		chapter_intro_panel.modulate.a = 0.0
		chapter_intro_panel.visible = true
		var tween := create_tween()
		tween.tween_property(chapter_intro_panel, "modulate:a", 1.0, 0.8)
		tween.tween_interval(2.5)
		tween.tween_property(chapter_intro_panel, "modulate:a", 0.0, 0.8)
		tween.tween_callback(func(): chapter_intro_panel.visible = false)

func _on_water_interacted(_interactor: Node2D) -> void:
	if water_collected:
		return
	water_collected = true
	water_interactable.is_interactable = false

	if AudioManager != null:
		AudioManager.play_sfx("sfx_item_collect")

	if StoryManager != null:
		StoryManager.add_community_support(30)
		StoryManager.add_journal_entry("story", "Oasis in the Wilderness", "Mekatilili replenished water stores in traditional calabashes to sustain their trek across the Rift Valley.")

	if QuestManager != null:
		QuestManager.complete_objective("quest_level_11", 0)

	if hud != null and hud.has_method("show_collectible_banner"):
		hud.show_collectible_banner("Water Replenished (+30% Endurance)", "Fresh mountain water secured for the journey east toward the savannah.")

func _on_herb_interacted(_interactor: Node2D) -> void:
	if herbs_collected:
		return
	herbs_collected = true
	herb_interactable.is_interactable = false

	if AudioManager != null:
		AudioManager.play_sfx("sfx_item_collect")

	if StoryManager != null:
		StoryManager.add_community_support(30)
		StoryManager.add_journal_entry("story", "Foraging the Escarpment", "Traditional medicinal herbs collected along the highland trails to heal foot sores and exhaustion.")

	if QuestManager != null:
		QuestManager.complete_objective("quest_level_11", 1)

	if hud != null and hud.has_method("show_collectible_banner"):
		hud.show_collectible_banner("Medicinal Herbs Gathered (+30% Endurance)", "Traditional remedies will sustain Mekatilili and Wanje as they enter the eastern plains.")

func _on_scout_interacted(_interactor: Node2D) -> void:
	if scout_evaded:
		return
	scout_evaded = true
	scout_interactable.is_interactable = false

	if AudioManager != null:
		AudioManager.play_sfx("sfx_quest_complete")

	if StoryManager != null:
		StoryManager.add_community_support(30)
		StoryManager.add_journal_entry("story", "Evading the Railway Telegraph", "Mekatilili slipped unseen past the colonial scouts guarding the Uganda Railway corridor.")

	if QuestManager != null:
		QuestManager.complete_objective("quest_level_11", 2)

	if hud != null and hud.has_method("show_collectible_banner"):
		hud.show_collectible_banner("Colonial Scouts Evaded (+30% Endurance)", "The coastal hills of Kilifi are visible on the eastern horizon! Reach Kaya Fungo ahead!")

	if reunion_interactable != null:
		reunion_interactable.marker_type = "quest"

func _on_reunion_interacted(_interactor: Node2D) -> void:
	if DialogueManager != null:
		DialogueManager.start_dialogue("dialogue_wilderness_return")

func _on_dialogue_ended(dialogue_id: String) -> void:
	if dialogue_id == "dialogue_wilderness_return":
		if AudioManager != null:
			AudioManager.play_sfx("sfx_quest_complete", 1.2)

		if StoryManager != null:
			StoryManager.add_journal_entry(
				"story",
				"The Eternal Kaya",
				"Mekatilili and Wanje arrived back in Kaya Fungo after walking over 1,000 kilometers on foot. Their return unified all coastal clans in the historic 1914 Giriama Uprising."
			)

		# Chapter III / Act III Completed!
		if GameManager != null:
			GameManager.current_level = 12
			GameManager.complete_current_chapter()

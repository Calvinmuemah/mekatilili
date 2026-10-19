class_name ChapterComplete
extends Control

@onready var panel: Control = $PanelContainer if has_node("PanelContainer") else $Panel
@onready var title_label: Label = $PanelContainer/MarginContainer/VBox/TitleLabel if has_node("PanelContainer/MarginContainer/VBox/TitleLabel") else $Panel/VBox/TitleLabel
@onready var chapter_label: Label = $PanelContainer/MarginContainer/VBox/ChapterLabel if has_node("PanelContainer/MarginContainer/VBox/ChapterLabel") else $Panel/VBox/ChapterLabel
@onready var summary_text: RichTextLabel = $PanelContainer/MarginContainer/VBox/SummaryText if has_node("PanelContainer/MarginContainer/VBox/SummaryText") else $Panel/VBox/SummaryText
@onready var continue_btn: Button = $PanelContainer/MarginContainer/VBox/ButtonsHBox/ContinueBtn if has_node("PanelContainer/MarginContainer/VBox/ButtonsHBox/ContinueBtn") else ($Panel/VBox/ContinueBtn if has_node("Panel/VBox/ContinueBtn") else null)
@onready var menu_btn: Button = $PanelContainer/MarginContainer/VBox/ButtonsHBox/MenuBtn if has_node("PanelContainer/MarginContainer/VBox/ButtonsHBox/MenuBtn") else ($Panel/VBox/MenuBtn if has_node("Panel/VBox/MenuBtn") else null)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	
	_style_screen()
	_populate_summary()
	
	if continue_btn != null and not continue_btn.pressed.is_connected(_on_continue_pressed):
		continue_btn.pressed.connect(_on_continue_pressed)
	if menu_btn != null and not menu_btn.pressed.is_connected(_on_menu_pressed):
		menu_btn.pressed.connect(_on_menu_pressed)
	
	if AudioManager != null:
		AudioManager.play_sfx("sfx_quest_complete")

	if SaveManager != null and SaveManager.has_signal("settings_changed"):
		SaveManager.settings_changed.connect(_style_screen)

func _style_screen() -> void:
	if panel != null:
		var style := GamePalette.create_panel_style(GamePalette.COLOR_SAND, GamePalette.COLOR_WARM_GOLD, 14, 4)
		panel.add_theme_stylebox_override("panel", style)
	
	if title_label != null:
		title_label.add_theme_color_override("font_color", GamePalette.COLOR_TERRACOTTA)
		title_label.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_H2))
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	if chapter_label != null:
		chapter_label.add_theme_color_override("font_color", GamePalette.COLOR_DEEP_EARTH)
		chapter_label.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BODY + 2))
		chapter_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		chapter_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	if summary_text != null:
		summary_text.add_theme_color_override("default_color", GamePalette.COLOR_CHARCOAL)
		summary_text.add_theme_font_size_override("normal_font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BODY))
		summary_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		summary_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	if continue_btn != null:
		GamePalette.apply_button_theme(continue_btn, GamePalette.COLOR_TERRACOTTA, GamePalette.FONT_SIZE_BUTTON)
	if menu_btn != null:
		GamePalette.apply_button_theme(menu_btn, GamePalette.COLOR_DEEP_EARTH, GamePalette.FONT_SIZE_BUTTON)

func _populate_summary() -> void:
	var num_collectibles := 0
	if StoryManager != null:
		num_collectibles = StoryManager.collectibles.size()
		
	var lvl := GameManager.current_level if GameManager != null else 1
	var bb := ""
	
	if lvl >= 12:
		title_label.text = "ACT III COMPLETED"
		chapter_label.text = "The Thousand-Kilometer Walk Home & The Eternal Kaya"
		bb += "[b]🎉 CHAPTER III & FULL HISTORICAL SAGA (LEVELS 1–11) COMPLETED![/b]\n\n"
		bb += "✓ [b]The Colonial Arrest:[/b] Mekatilili and Wanje stood unbroken in chains\n"
		bb += "✓ [b]Kisii Prison Breakout:[/b] Infiltrated the warden post and breached the stockade gates\n"
		bb += "✓ [b]The 1,000-Kilometer Trek:[/b] Survived wilderness springs, Rift Valley trails, and evaded railway scouts\n"
		bb += "✓ [b]Triumphant Return:[/b] Reunited at Kaya Fungo — [i]\"I told you I would return\"[/i]\n\n"
		bb += "[color=#315C3A][b]Historical Reflection:[/b][/color]\n"
		bb += "In 1914, Mekatilili wa Menza and Wanje wa Mwadorikola's miraculous return on foot sparked the full-scale Giriama Uprising. Their defiance forced the British colonial government to abandon compulsory labor recruitment in Giriama territory and respect sacred Kaya sanctuaries. Mekatilili remains one of Kenya's greatest national heroes.\n\n"
		bb += "[i]You have mastered the complete historical epic of Mekatilili wa Menza![/i]"
		
		if continue_btn != null:
			continue_btn.text = "▶  REPLAY FULL SAGA (LEVELS 1–11)"
		if menu_btn != null:
			menu_btn.text = "MAIN MENU"
	elif lvl >= 8:
		title_label.text = "CHAPTER II COMPLETED"
		chapter_label.text = "The Fire of Kifudu & The Kwa Junda Escape"
		bb += "[b]🎉 CHAPTER II (LEVELS 2–7) SUCCESSFULLY COMPLETED![/b]\n\n"
		bb += "✓ [b]Resistance Circuit Completed:[/b] Bungale, Vitengeni, and Kaya Fungo clusters united\n"
		bb += "✓ [b]The Kifudu Gathering:[/b] Delivered the historic address (\"We are not powerless\")\n"
		bb += "✓ [b]The Hen and Chicks Parable:[/b] Openly defied District Commissioner Arthur Champion\n"
		bb += "✓ [b]Compound Escape:[/b] Evaded colonial sentries and secured freedom in the hinterlands\n\n"
		bb += "[color=#D9A441][b]Next: Act III — Banishment & The Thousand-Kilometer Walk Home (Levels 8–11)[/b][/color]\n"
		bb += "Colonial forces have tracked the resistance leaders to the coastal ridge. Face the arrest detachment under Captain Phillips and begin the journey to Kisii Prison!\n\n"
		bb += "[i]Tap below to begin Act III — Level 8: The Betrayal & The Long Chains.[/i]"
		
		if continue_btn != null:
			continue_btn.text = "▶  PROCEED TO ACT III (LEVEL 8)"
		if menu_btn != null:
			menu_btn.text = "MAIN MENU"
	else:
		title_label.text = "CHAPTER I COMPLETED"
		chapter_label.text = "Whispers in the Palms"
		bb += "[b]Chapter I: Whispers in the Palms — COMPLETED![/b]\n\n"
		bb += "✓ [b]Community Support:[/b] 100% (The village of Ulungu stands united)\n"
		bb += "✓ [b]Allies Joined:[/b] Mzee Fondo, Wanje wa Mwadorikola, Warrior Charo, Villager Nyevu\n"
		bb += "✓ [b]Cultural Artifacts Discovered:[/b] " + str(num_collectibles) + " / 3\n\n"
		bb += "[color=#D9A441][b]What's Next:[/b][/color]\n"
		bb += "British colonial notices have arrived at the village boundary. In [b]Chapter II (Level 2)[/b], you will inspect the proclamation, confront the colonial runner, and plan the resistance circuit with Wanje!\n\n"
		bb += "[i]Tap below to enter Chapter II — Level 2 & 3: Colonial Shift & The Wanje Alliance.[/i]"
		
		if continue_btn != null:
			continue_btn.text = "▶  PROCEED TO CHAPTER II (LEVEL 2)"
		if menu_btn != null:
			menu_btn.text = "MAIN MENU"
	
	summary_text.text = bb

func _on_continue_pressed() -> void:
	# 1. Unpause the game tree
	get_tree().paused = false
	
	var lvl := GameManager.current_level if GameManager != null else 1
	var next_scene_path := ""
	
	if lvl >= 12:
		# Player finished the entire saga -> Replay from Level 1
		if GameManager != null:
			GameManager.current_chapter = 1
			GameManager.current_level = 1
		next_scene_path = "res://scenes/environments/VillageLevel.tscn"
		if SaveManager != null:
			SaveManager.save_game({
				"chapter": 1,
				"level": 1,
				"scene": "res://scenes/environments/VillageLevel.tscn",
				"chapter_3_completed": true,
				"chapter_2_completed": true,
				"chapter_1_completed": true
			})
	elif lvl >= 8:
		# Player finished Chapter 2 -> Proceed to Act III (Level 8: ArrestSequence)
		if GameManager != null:
			GameManager.current_chapter = 3
			GameManager.current_level = 8
		next_scene_path = "res://scenes/cinematics/ArrestSequence.tscn"
		if SaveManager != null:
			SaveManager.save_game({
				"chapter": 3,
				"level": 8,
				"scene": "res://scenes/cinematics/ArrestSequence.tscn",
				"chapter_2_completed": true
			})
	elif lvl == 2:
		# Chapter 1 complete -> Proceed straight to Level 2 in the Village
		if GameManager != null:
			GameManager.current_chapter = 2
			GameManager.current_level = 2
		next_scene_path = "res://scenes/environments/VillageLevel.tscn"
		if SaveManager != null:
			SaveManager.save_game({
				"chapter": 2,
				"level": 2,
				"scene": "res://scenes/environments/VillageLevel.tscn",
				"chapter_1_completed": true
			})
	else:
		if GameManager != null:
			GameManager.current_chapter = 2
			GameManager.current_level = 2
		next_scene_path = "res://scenes/environments/VillageLevel.tscn"
		if SaveManager != null:
			SaveManager.save_game({
				"chapter": 2,
				"level": 2,
				"scene": "res://scenes/environments/VillageLevel.tscn"
			})
		
	# Perform clean transition fading
	if SceneManager != null:
		SceneManager.change_scene(next_scene_path)
	else:
		get_tree().change_scene_to_file(next_scene_path)

func _on_menu_pressed() -> void:
	get_tree().paused = false
	var lvl := GameManager.current_level if GameManager != null else 1
	if SaveManager != null:
		if lvl >= 12:
			SaveManager.save_game({
				"chapter": 3,
				"level": 12,
				"chapter_3_completed": true,
				"chapter_2_completed": true,
				"scene": "res://scenes/environments/WildernessTrek.tscn"
			})
		elif lvl >= 8:
			SaveManager.save_game({
				"chapter": 2,
				"level": 8,
				"chapter_2_completed": true,
				"scene": "res://scenes/environments/ColonialStation.tscn"
			})
		elif lvl == 2:
			SaveManager.save_game({
				"chapter": 2,
				"level": 2,
				"scene": "res://scenes/environments/VillageLevel.tscn",
				"chapter_1_completed": true
			})
	if SceneManager != null:
		SceneManager.change_scene("res://scenes/main/MainMenu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")



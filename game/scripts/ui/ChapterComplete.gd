class_name ChapterComplete
extends Control

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var chapter_label: Label = $Panel/VBox/ChapterLabel
@onready var summary_text: RichTextLabel = $Panel/VBox/SummaryText
@onready var continue_btn: Button = $Panel/VBox/ContinueBtn
@onready var menu_btn: Button = $Panel/VBox/MenuBtn

func _ready() -> void:
	_style_screen()
	_populate_summary()
	
	continue_btn.pressed.connect(_on_continue_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	
	if AudioManager != null:
		AudioManager.play_sfx("sfx_quest_complete")

func _style_screen() -> void:
	var style := GamePalette.create_panel_style(GamePalette.COLOR_SAND, GamePalette.COLOR_WARM_GOLD, 14, 4)
	panel.add_theme_stylebox_override("panel", style)
	
	title_label.add_theme_color_override("font_color", GamePalette.COLOR_TERRACOTTA)
	title_label.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_H1)
	
	chapter_label.add_theme_color_override("font_color", GamePalette.COLOR_DEEP_EARTH)
	chapter_label.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_CHAPTER)
	
	summary_text.add_theme_color_override("default_color", GamePalette.COLOR_CHARCOAL)
	summary_text.add_theme_font_size_override("normal_font_size", GamePalette.FONT_SIZE_BODY)
	
	GamePalette.apply_button_theme(continue_btn, GamePalette.COLOR_TERRACOTTA)
	GamePalette.apply_button_theme(menu_btn, GamePalette.COLOR_DEEP_EARTH)

func _populate_summary() -> void:
	var num_collectibles := 0
	if StoryManager != null:
		num_collectibles = StoryManager.collectibles.size()
		
	var bb := ""
	bb += "[b]Chapter I: Whispers in the Palms — COMPLETED![/b]\n\n"
	bb += "✓ [b]Community Support:[/b] 100% (The village of Ulungu stands united)\n"
	bb += "✓ [b]Allies Joined:[/b] Mzee Fondo, Wanje wa Mwadorikola, Warrior Charo, Villager Nyevu\n"
	bb += "✓ [b]Cultural Artifacts Discovered:[/b] " + str(num_collectibles) + " / 3\n\n"
	bb += "[color=#315C3A][b]Historical Reflection:[/b][/color]\n"
	bb += "In 1913, Mekatilili wa Menza's organizing in the coastal hinterlands set into motion an unprecedented coalition. Rejecting forced labor recruitment and unfair poll taxes, she demonstrated that community unity was stronger than imperial mandates.\n\n"
	bb += "[i]Next Chapter: The Fire of Kifudu & The Kwa Junda Confrontation...[/i]"
	
	summary_text.text = bb

func _on_continue_pressed() -> void:
	# Save progress and return to menu or replay
	if SaveManager != null:
		SaveManager.save_game({"chapter": 1, "completed": true})
	SceneManager.change_scene("res://scenes/main/MainMenu.tscn")

func _on_menu_pressed() -> void:
	SceneManager.change_scene("res://scenes/main/MainMenu.tscn")

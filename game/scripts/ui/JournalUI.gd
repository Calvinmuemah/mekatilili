class_name JournalUI
extends Control

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/TitleLabel
@onready var close_btn: Button = $Panel/CloseBtn

@onready var tab_story: Button = $Panel/TabBar/StoryTab
@onready var tab_quests: Button = $Panel/TabBar/QuestsTab
@onready var tab_history: Button = $Panel/TabBar/HistoryTab
@onready var tab_collectibles: Button = $Panel/TabBar/CollectiblesTab

@onready var content_text: RichTextLabel = $Panel/ContentScroll/ContentText

var current_tab: String = "story"

func _ready() -> void:
	visible = false
	_style_journal()
	
	close_btn.pressed.connect(func(): visible = false)
	tab_story.pressed.connect(func(): _switch_tab("story"))
	tab_quests.pressed.connect(func(): _switch_tab("quests"))
	tab_history.pressed.connect(func(): _switch_tab("history"))
	tab_collectibles.pressed.connect(func(): _switch_tab("collectibles"))

func _style_journal() -> void:
	var style := GamePalette.create_panel_style(GamePalette.COLOR_SAND, GamePalette.COLOR_WARM_GOLD, 12, 3)
	panel.add_theme_stylebox_override("panel", style)
	
	title_label.add_theme_color_override("font_color", GamePalette.COLOR_DEEP_EARTH)
	title_label.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_H1)
	
	GamePalette.apply_button_theme(close_btn, GamePalette.COLOR_DEEP_EARTH)
	GamePalette.apply_button_theme(tab_story, GamePalette.COLOR_TERRACOTTA)
	GamePalette.apply_button_theme(tab_quests, GamePalette.COLOR_TERRACOTTA)
	GamePalette.apply_button_theme(tab_history, GamePalette.COLOR_TERRACOTTA)
	GamePalette.apply_button_theme(tab_collectibles, GamePalette.COLOR_TERRACOTTA)
	
	content_text.add_theme_color_override("default_color", GamePalette.COLOR_CHARCOAL)
	content_text.add_theme_font_size_override("normal_font_size", GamePalette.FONT_SIZE_BODY)

func refresh() -> void:
	_switch_tab(current_tab)

func _switch_tab(tab_name: String) -> void:
	current_tab = tab_name
	if AudioManager != null:
		AudioManager.play_sfx("sfx_click")
		
	var bb := ""
	match tab_name:
		"story":
			bb = "[b][font_size=20]Story Timeline[/font_size][/b]\n\n"
			if StoryManager != null and StoryManager.journal_data.has("story"):
				var entries: Array = StoryManager.journal_data["story"]
				if entries.is_empty():
					bb += "The journey has just begun. Explore the village to uncover events."
				else:
					for e in entries:
						bb += "[color=#B85C38]• " + e.get("title", "") + "[/color]\n"
						bb += e.get("content", "") + "\n\n"
						
		"quests":
			bb = "[b][font_size=20]Objectives & Missions[/font_size][/b]\n\n"
			if QuestManager != null:
				var q := QuestManager.get_active_quest()
				if not q.is_empty():
					bb += "[color=#315C3A]Active Quest: " + q.get("title", "") + "[/color]\n"
					bb += q.get("description", "") + "\n\n"
					bb += "[b]Steps:[/b]\n"
					for obj in q.get("objectives", []):
						var status := "[X] " if obj.get("completed", false) else "[ ] "
						bb += status + obj.get("description", "") + "\n"
				else:
					bb += "No active quests at this time."
					
		"history":
			bb = "[b][font_size=20]Historical Archives[/font_size][/b]\n\n"
			if StoryManager != null and StoryManager.journal_data.has("history"):
				for e in StoryManager.journal_data["history"]:
					bb += "[color=#D9A441]★ " + e.get("title", "") + "[/color]\n"
					bb += e.get("content", "") + "\n\n"
					
		"collectibles":
			bb = "[b][font_size=20]Cultural Artifacts[/font_size][/b]\n\n"
			if StoryManager != null:
				if StoryManager.collectibles.is_empty():
					bb += "No artifacts collected yet. Inspect traditional objects in the environment."
				else:
					for c in StoryManager.collectibles:
						bb += "[color=#B85C38]◆ " + c.get("name", "") + "[/color]\n"
						bb += c.get("description", "") + "\n"
						bb += "[i]Historical Note: " + c.get("historical_note", "") + "[/i]\n\n"
						
	content_text.text = bb

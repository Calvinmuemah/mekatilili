class_name HUD
extends CanvasLayer

@onready var character_label: Label = $TopLeft/Panel/VBox/CharLabel
@onready var support_bar: ProgressBar = $TopLeft/Panel/VBox/SupportBar
@onready var support_label: Label = $TopLeft/Panel/VBox/SupportLabel

@onready var journal_btn: Button = $TopRight/VBox/ButtonsHBox/JournalBtn
@onready var pause_btn: Button = $TopRight/VBox/ButtonsHBox/PauseBtn
@onready var objective_panel: Panel = $TopRight/VBox/ObjectivePanel
@onready var objective_title: Label = $TopRight/VBox/ObjectivePanel/VBox/TitleLabel
@onready var objective_text: Label = $TopRight/VBox/ObjectivePanel/VBox/DescLabel

@onready var prompt_panel: Panel = $BottomCenter/PromptPanel
@onready var prompt_label: Label = $BottomCenter/PromptPanel/PromptLabel

@onready var top_center: Control = $TopCenter
@onready var banner_panel: Panel = $TopCenter/BannerPanel
@onready var banner_title: Label = $TopCenter/BannerPanel/VBox/BannerTitle
@onready var banner_desc: Label = $TopCenter/BannerPanel/VBox/BannerDesc

@onready var touch_controls: TouchControls = $TouchControls
@onready var dialogue_box: DialogueBox = $DialogueBox
@onready var journal_overlay: Control = $JournalOverlay
@onready var pause_overlay: Control = $PauseOverlay

var banner_tween: Tween = null

func _ready() -> void:
	add_to_group("hud")
	_style_hud()
	_update_support(StoryManager.community_support if StoryManager != null else 0)
	_update_objective()
	set_interaction_prompt("")
	
	banner_panel.modulate.a = 0.0
	if top_center != null:
		top_center.position.y = -90.0
	
	if journal_btn != null:
		journal_btn.pressed.connect(toggle_journal)
	if pause_btn != null:
		pause_btn.pressed.connect(_on_pause_pressed)
	
	if StoryManager != null:
		StoryManager.community_support_changed.connect(_update_support)
		
	if QuestManager != null:
		QuestManager.quest_started.connect(_on_quest_started)
		QuestManager.objective_updated.connect(_on_objective_updated)
		QuestManager.quest_completed.connect(_on_quest_completed)
		
	if DialogueManager != null:
		DialogueManager.dialogue_started.connect(func(_id): _set_hud_visible(false))
		DialogueManager.dialogue_ended.connect(func(_id): _set_hud_visible(true))
		
	if SaveManager != null and SaveManager.has_signal("settings_changed"):
		SaveManager.settings_changed.connect(_style_hud)

func _style_hud() -> void:
	# Top left panel
	var panel_left: Panel = $TopLeft/Panel
	var style_left := GamePalette.create_panel_style(GamePalette.COLOR_DEEP_EARTH, GamePalette.COLOR_WARM_GOLD, 8, 2)
	panel_left.add_theme_stylebox_override("panel", style_left)
	character_label.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
	character_label.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BODY))
	support_label.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)
	support_label.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_CAPTION))
	
	# Support bar progress styling
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.18, 0.12, 0.08, 0.8)
	bar_bg.set_corner_radius_all(4)
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = GamePalette.COLOR_WARM_GOLD
	bar_fill.set_corner_radius_all(4)
	support_bar.add_theme_stylebox_override("background", bar_bg)
	support_bar.add_theme_stylebox_override("fill", bar_fill)
	
	# Top right header buttons
	if journal_btn != null:
		GamePalette.apply_button_theme(journal_btn, GamePalette.COLOR_FOREST_GREEN, GamePalette.FONT_SIZE_CAPTION + 1)
	if pause_btn != null:
		GamePalette.apply_button_theme(pause_btn, GamePalette.COLOR_DEEP_EARTH, GamePalette.FONT_SIZE_CAPTION + 1)
	
	# Top right objective panel
	var style_right := GamePalette.create_panel_style(GamePalette.COLOR_DEEP_EARTH, GamePalette.COLOR_TERRACOTTA, 8, 2)
	objective_panel.add_theme_stylebox_override("panel", style_right)
	objective_title.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
	objective_title.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_CAPTION))
	objective_text.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)
	objective_text.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BODY))
	
	# Bottom prompt panel
	var style_prompt := GamePalette.create_panel_style(GamePalette.COLOR_SAND, GamePalette.COLOR_TERRACOTTA, 20, 2)
	prompt_panel.add_theme_stylebox_override("panel", style_prompt)
	prompt_label.add_theme_color_override("font_color", GamePalette.COLOR_CHARCOAL)
	prompt_label.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BUTTON))
	
	# Banner panel (Drop-down toast)
	var style_banner := GamePalette.create_panel_style(GamePalette.COLOR_TERRACOTTA, GamePalette.COLOR_WARM_GOLD, 8, 3)
	banner_panel.add_theme_stylebox_override("panel", style_banner)
	banner_title.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
	banner_title.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_H2))
	banner_desc.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)
	banner_desc.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BODY))

func _update_support(val: int) -> void:
	if support_bar != null:
		support_bar.value = val
	if support_label != null:
		support_label.text = "Community Unity: " + str(val) + "%"

func _update_objective() -> void:
	if QuestManager != null:
		objective_text.text = QuestManager.get_current_objective_text()

func set_interaction_prompt(msg: String) -> void:
	if msg == "":
		prompt_panel.visible = false
	else:
		prompt_label.text = "[E / TAP] " + msg
		prompt_panel.visible = true

func _set_hud_visible(val: bool) -> void:
	$TopLeft.visible = val
	$TopRight.visible = val
	if not val:
		prompt_panel.visible = false

func _on_quest_started(_qid: String, qtitle: String, qdesc: String) -> void:
	show_collectible_banner("NEW QUEST: " + qtitle, qdesc)
	_update_objective()

func _on_objective_updated(_qid: String, _idx: int, obj_desc: String) -> void:
	objective_text.text = obj_desc
	show_collectible_banner("OBJECTIVE UPDATED", obj_desc)

func _on_quest_completed(_qid: String, qtitle: String) -> void:
	show_collectible_banner("QUEST COMPLETED!", qtitle)
	objective_text.text = "All objectives fulfilled."

func show_collectible_banner(title: String, desc: String) -> void:
	banner_title.text = title
	banner_desc.text = desc
	
	if banner_tween != null and banner_tween.is_valid():
		banner_tween.kill()
		
	if top_center == null:
		top_center = $TopCenter
	
	top_center.position.y = -90.0
	banner_panel.modulate.a = 0.0
	banner_panel.visible = true
	
	banner_tween = create_tween()
	# Drop down with spring ease
	banner_tween.tween_property(top_center, "position:y", 20.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	banner_tween.parallel().tween_property(banner_panel, "modulate:a", 1.0, 0.3)
	# Display duration
	banner_tween.tween_interval(3.2)
	# Fade and slide back up
	banner_tween.tween_property(top_center, "position:y", -90.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	banner_tween.parallel().tween_property(banner_panel, "modulate:a", 0.0, 0.3)

func toggle_journal() -> void:
	if journal_overlay != null:
		journal_overlay.visible = not journal_overlay.visible
		if journal_overlay.visible and journal_overlay.has_method("refresh"):
			journal_overlay.refresh()

func _on_pause_pressed() -> void:
	if GameManager != null:
		GameManager.toggle_pause()

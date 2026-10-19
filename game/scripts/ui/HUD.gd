class_name HUD
extends CanvasLayer

@onready var character_label: Label = $TopLeft/Panel/HBox/VBox/CharLabel if has_node("TopLeft/Panel/HBox/VBox/CharLabel") else $TopLeft/Panel/VBox/CharLabel
@onready var support_bar: ProgressBar = $TopLeft/Panel/HBox/VBox/SupportBar if has_node("TopLeft/Panel/HBox/VBox/SupportBar") else $TopLeft/Panel/VBox/SupportBar
@onready var support_label: Label = $TopLeft/Panel/HBox/VBox/SupportLabel if has_node("TopLeft/Panel/HBox/VBox/SupportLabel") else $TopLeft/Panel/VBox/SupportLabel

@onready var journal_btn: Button = $TopRight/VBox/ButtonsHBox/JournalBtn
@onready var pause_btn: Button = $TopRight/VBox/ButtonsHBox/PauseBtn
@onready var objective_panel: Control = $TopRight/VBox/ObjectivePanel
@onready var objective_title: Label = $TopRight/VBox/ObjectivePanel/Margin/VBox/TitleLabel if has_node("TopRight/VBox/ObjectivePanel/Margin/VBox/TitleLabel") else $TopRight/VBox/ObjectivePanel/VBox/TitleLabel
@onready var objective_text: Label = $TopRight/VBox/ObjectivePanel/Margin/VBox/DescLabel if has_node("TopRight/VBox/ObjectivePanel/Margin/VBox/DescLabel") else $TopRight/VBox/ObjectivePanel/VBox/DescLabel

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
	banner_panel.visible = false
	if top_center != null:
		top_center.visible = false
	
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
	objective_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Bottom prompt panel
	var style_prompt := GamePalette.create_panel_style(GamePalette.COLOR_SAND, GamePalette.COLOR_TERRACOTTA, 20, 2)
	style_prompt.content_margin_left = 20
	style_prompt.content_margin_right = 20
	style_prompt.content_margin_top = 8
	style_prompt.content_margin_bottom = 8
	prompt_panel.add_theme_stylebox_override("panel", style_prompt)
	prompt_label.add_theme_color_override("font_color", GamePalette.COLOR_CHARCOAL)
	prompt_label.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BUTTON))
	
	# Banner panel (Drop-down toast)
	var style_banner := GamePalette.create_panel_style(GamePalette.COLOR_DEEP_EARTH, GamePalette.COLOR_WARM_GOLD, 10, 3)
	style_banner.content_margin_left = 24
	style_banner.content_margin_right = 24
	style_banner.content_margin_top = 12
	style_banner.content_margin_bottom = 12
	banner_panel.add_theme_stylebox_override("panel", style_banner)
	banner_title.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
	banner_title.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BODY + 2))
	banner_desc.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)
	banner_desc.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_CAPTION + 1))

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
		if touch_controls != null and touch_controls.has_method("set_prompt"):
			touch_controls.set_prompt("")
		return

	# Strip all keyboard and tap prefixes, displaying only the action words
	var clean_msg := msg
	clean_msg = clean_msg.replace("[E / TAP]", "")
	clean_msg = clean_msg.replace("[E/TAP]", "")
	clean_msg = clean_msg.replace("[E /", "")
	clean_msg = clean_msg.replace("[E]", "")
	clean_msg = clean_msg.replace("[e]", "")
	clean_msg = clean_msg.replace("[TAP]", "")
	clean_msg = clean_msg.replace("[tap]", "")
	clean_msg = clean_msg.replace("TAP]", "")
	clean_msg = clean_msg.replace("TAP", "")
	clean_msg = clean_msg.strip_edges()
	if clean_msg.begins_with(":") or clean_msg.begins_with("-"):
		clean_msg = clean_msg.substr(1).strip_edges()

	# Display clean words only - always keep the prompt card visible
	prompt_label.text = clean_msg
	prompt_panel.visible = true

	# Forward to touch button if touch controls are loaded
	if touch_controls != null and touch_controls.has_method("set_prompt"):
		touch_controls.set_prompt(clean_msg)

	# Dynamically stretch the card to fit all words without clipping
	_stretch_prompt_card(clean_msg)

func _stretch_prompt_card(text: String) -> void:
	if prompt_label == null or prompt_panel == null:
		return

	var font: Font = prompt_label.get_theme_font("font")
	if font == null:
		font = ThemeDB.fallback_font
	var font_size: int = prompt_label.get_theme_font_size("font_size")
	if font_size <= 0:
		font_size = GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BUTTON)

	var h_padding: float = 48.0 # 24px left + 24px right
	var v_padding: float = 16.0 # 8px top + 8px bottom
	var min_width: float = 220.0
	var max_width: float = 560.0
	var min_height: float = 46.0

	var text_size := Vector2.ZERO
	if font != null:
		text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	else:
		text_size = Vector2(text.length() * 11.0, 22.0)

	var needed_width: float = text_size.x + h_padding
	var final_width: float = clampf(needed_width, min_width, max_width)
	var final_height: float = min_height

	if needed_width > max_width:
		prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var available_w: float = final_width - h_padding
		var multiline_size := Vector2.ZERO
		if font != null:
			multiline_size = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, available_w, font_size)
		else:
			var lines := ceilf(text_size.x / available_w)
			multiline_size = Vector2(available_w, lines * 24.0)
		final_height = maxf(min_height, multiline_size.y + v_padding + 6.0)
	else:
		prompt_label.autowrap_mode = TextServer.AUTOWRAP_OFF

	var bottom_c: Control = get_node_or_null("BottomCenter") as Control
	if bottom_c != null:
		bottom_c.offset_left = -final_width / 2.0
		bottom_c.offset_right = final_width / 2.0
		bottom_c.offset_bottom = -25.0
		bottom_c.offset_top = -25.0 - final_height


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
	if banner_panel == null:
		banner_panel = $TopCenter/BannerPanel

	_stretch_banner_card(title, desc)
	
	top_center.visible = true
	banner_panel.visible = true
	banner_panel.modulate.a = 0.0
	
	banner_tween = create_tween()
	# Smooth fade in toast
	banner_tween.tween_property(banner_panel, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Display duration
	banner_tween.tween_interval(3.2)
	# Fade back out
	banner_tween.tween_property(banner_panel, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	banner_tween.tween_callback(func():
		banner_panel.visible = false
		if top_center != null:
			top_center.visible = false
	)

func _stretch_banner_card(title: String, desc: String) -> void:
	if banner_title == null or banner_desc == null or top_center == null:
		return

	var font: Font = banner_desc.get_theme_font("font")
	if font == null:
		font = ThemeDB.fallback_font

	var desc_font_size: int = banner_desc.get_theme_font_size("font_size")
	if desc_font_size <= 0:
		desc_font_size = GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_CAPTION + 1)

	var title_font_size: int = banner_title.get_theme_font_size("font_size")
	if title_font_size <= 0:
		title_font_size = GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BODY + 2)

	var fixed_width: float = 560.0
	var h_padding: float = 48.0 # 24px left + 24px right
	var v_padding: float = 28.0 # 14px top + 14px bottom
	var available_w: float = fixed_width - h_padding

	var title_size := Vector2.ZERO
	if font != null:
		title_size = font.get_multiline_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, available_w, title_font_size)
	else:
		title_size = Vector2(available_w, 24.0)
	var title_h: float = maxf(22.0, title_size.y)

	var desc_size := Vector2.ZERO
	if font != null:
		desc_size = font.get_multiline_string_size(desc, HORIZONTAL_ALIGNMENT_CENTER, available_w, desc_font_size)
	else:
		desc_size = Vector2(available_w, 22.0)
	var desc_h: float = maxf(20.0, desc_size.y)

	var separation: float = 6.0
	var calculated_height: float = title_h + separation + desc_h + v_padding
	var final_height: float = maxf(86.0, ceilf(calculated_height))

	top_center.offset_left = -fixed_width / 2.0
	top_center.offset_right = fixed_width / 2.0
	top_center.offset_top = 16.0
	top_center.offset_bottom = 16.0 + final_height

func toggle_journal() -> void:
	if journal_overlay != null:
		journal_overlay.visible = not journal_overlay.visible
		if journal_overlay.visible and journal_overlay.has_method("refresh"):
			journal_overlay.refresh()

func _on_pause_pressed() -> void:
	if GameManager != null:
		GameManager.toggle_pause()

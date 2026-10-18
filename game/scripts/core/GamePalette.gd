extends Node

# Centralized Game Color Palette
const COLOR_DEEP_EARTH   := Color("#3B2416") # RGB 59, 36, 22
const COLOR_TERRACOTTA   := Color("#B85C38") # RGB 184, 92, 56
const COLOR_WARM_GOLD    := Color("#D9A441") # RGB 217, 164, 65
const COLOR_FOREST_GREEN := Color("#315C3A") # RGB 49, 92, 58
const COLOR_SAND         := Color("#E8D3A8") # RGB 232, 211, 168
const COLOR_IVORY        := Color("#F7F0DE") # RGB 247, 240, 222
const COLOR_CHARCOAL     := Color("#211C18") # RGB 33, 28, 24

# Typography Font Sizes
const FONT_SIZE_H1 := 32
const FONT_SIZE_H2 := 24
const FONT_SIZE_CHAPTER := 28
const FONT_SIZE_BODY := 16
const FONT_SIZE_DIALOGUE := 18
const FONT_SIZE_BUTTON := 18
const FONT_SIZE_CAPTION := 14
const FONT_SIZE_QUEST := 16
const FONT_SIZE_HISTORICAL := 15

# Helper to calculate accessibility-scaled font sizes
static func get_scaled_font_size(base_size: int) -> int:
	var mult: float = 1.0
	var main_loop := Engine.get_main_loop()
	if main_loop != null and main_loop is SceneTree:
		var root: Window = (main_loop as SceneTree).root
		if root != null:
			var sm: Node = root.get_node_or_null("SaveManager")
			if sm != null and "current_settings" in sm:
				if sm.current_settings.get("large_text", false):
					mult = 1.35
				else:
					mult = float(sm.current_settings.get("text_size_multiplier", 1.0))
	return int(round(base_size * mult))

# Helper to create a stylized Flat StyleBox
static func create_panel_style(bg_color: Color = COLOR_SAND, border_color: Color = COLOR_WARM_GOLD, corner_radius: int = 8, border_width: int = 2) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.border_color = border_color
	sb.set_border_width_all(border_width)
	sb.set_corner_radius_all(corner_radius)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	return sb

static func create_button_style(bg_color: Color = COLOR_TERRACOTTA, border_color: Color = COLOR_WARM_GOLD, corner_radius: int = 6) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.border_color = border_color
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(corner_radius)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	return sb

static func apply_button_theme(button: Button, base_color: Color = COLOR_TERRACOTTA, custom_font_size: int = -1) -> void:
	button.add_theme_color_override("font_color", COLOR_IVORY)
	button.add_theme_color_override("font_hover_color", COLOR_WARM_GOLD)
	button.add_theme_color_override("font_pressed_color", COLOR_SAND)
	button.add_theme_color_override("font_disabled_color", COLOR_CHARCOAL)
	
	var fsize := get_scaled_font_size(FONT_SIZE_BUTTON if custom_font_size <= 0 else custom_font_size)
	button.add_theme_font_size_override("font_size", fsize)
	
	var normal_box := create_button_style(base_color, COLOR_WARM_GOLD)
	var hover_box := create_button_style(base_color.lightened(0.15), COLOR_IVORY)
	var pressed_box := create_button_style(base_color.darkened(0.2), COLOR_WARM_GOLD)
	var disabled_box := create_button_style(COLOR_CHARCOAL.lightened(0.1), COLOR_CHARCOAL)
	
	button.add_theme_stylebox_override("normal", normal_box)
	button.add_theme_stylebox_override("hover", hover_box)
	button.add_theme_stylebox_override("pressed", pressed_box)
	button.add_theme_stylebox_override("disabled", disabled_box)
	button.add_theme_stylebox_override("focus", hover_box)


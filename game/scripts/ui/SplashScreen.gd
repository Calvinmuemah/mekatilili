extends Control

@onready var emblem: TextureRect = $CenterContainer/VBox/Emblem
@onready var title_label: Label = $CenterContainer/VBox/TitleLabel
@onready var subtitle_label: Label = $CenterContainer/VBox/SubtitleLabel

func _ready() -> void:
	# Style colors
	title_label.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
	title_label.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_H1 + 6)
	
	subtitle_label.add_theme_color_override("font_color", GamePalette.COLOR_IVORY)
	subtitle_label.add_theme_font_size_override("font_size", GamePalette.FONT_SIZE_BODY)
	
	# Start with transparent elements
	emblem.modulate.a = 0.0
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	
	_animate_splash()

func _animate_splash() -> void:
	var tween := create_tween()
	# Fade in emblem & title
	tween.tween_property(emblem, "modulate:a", 1.0, 0.8)
	tween.parallel().tween_property(title_label, "modulate:a", 1.0, 0.8)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 0.6)
	tween.tween_interval(1.2)
	tween.tween_callback(func():
		SceneManager.change_scene("res://scenes/main/MainMenu.tscn", 0.6)
	)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.is_pressed():
			# Allow tap/key to skip to main menu
			SceneManager.change_scene("res://scenes/main/MainMenu.tscn", 0.3)

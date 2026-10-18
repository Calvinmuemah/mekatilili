extends CanvasLayer

signal transition_started(target_scene: String)
signal scene_loaded(scene_path: String)
signal transition_finished()

var overlay: ColorRect
var is_transitioning: bool = false

func _ready() -> void:
	layer = 100 # On top of everything
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color("#3B2416") # Deep Earth transition color
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.modulate.a = 0.0
	add_child(overlay)

func change_scene(scene_path: String, fade_time: float = 0.4) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	transition_started.emit(scene_path)
	
	# Ensure tree is unpaused so scene transitions never hang
	get_tree().paused = false
	
	# Block input during transition
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(overlay, "modulate:a", 1.0, fade_time)
	tween.tween_callback(func():
		var err := get_tree().change_scene_to_file(scene_path)
		if err != OK:
			push_error("SceneManager: Failed to load scene at " + scene_path)
			overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			is_transitioning = false
		scene_loaded.emit(scene_path)
		if GameManager != null:
			GameManager.current_scene_path = scene_path
	)
	tween.tween_interval(0.1) # brief pause at full cover
	tween.tween_property(overlay, "modulate:a", 0.0, fade_time)
	tween.tween_callback(func():
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		is_transitioning = false
		transition_finished.emit()
	)

func fade_to_black(duration: float = 0.5) -> Tween:
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, duration)
	return tween

func fade_from_black(duration: float = 0.5) -> Tween:
	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, duration)
	tween.tween_callback(func():
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)
	return tween

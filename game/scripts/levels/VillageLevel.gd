class_name VillageLevel
extends Node2D

@onready var player: PlayerController = $Player
@onready var hud: HUD = $HUD
@onready var chapter_intro_panel: Panel = $HUD/ChapterIntroPanel
@onready var chapter_intro_title: Label = $HUD/ChapterIntroPanel/VBox/Title
@onready var chapter_intro_sub: Label = $HUD/ChapterIntroPanel/VBox/Subtitle

var colonial_notice_node: Node2D = null
var colonial_runner_node: Node2D = null
var clusters_spawned: bool = false
var gateway_spawned: bool = false

func _ready() -> void:
	if GameManager != null:
		GameManager.set_game_state(GameManager.GameState.IN_GAME)
		GameManager.current_scene_path = scene_file_path
		
	if AudioManager != null:
		AudioManager.play_ambient("res://assets/audio/ambient_coastal_loop.wav")
		AudioManager.play_music("res://assets/audio/music_intro_loop.wav")
		
	_setup_camera_limits()
	
	if DialogueManager != null:
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
		
	if StoryManager != null:
		StoryManager.community_support_changed.connect(_on_community_support_changed)
		
	if QuestManager != null:
		QuestManager.quest_completed.connect(func(q_id, _title):
			if q_id == "quest_chapter_1":
				_setup_level_2_state()
		)
		
	_check_and_apply_level_state()
	
	if SaveManager != null:
		SaveManager.save_game({
			"chapter": GameManager.current_chapter if GameManager != null else 1,
			"level": GameManager.current_level if GameManager != null else 1
		})

func _setup_camera_limits() -> void:
	if player != null:
		var cam: Camera2D = player.get_node_or_null("Camera2D")
		if cam != null:
			cam.limit_left = 0
			cam.limit_top = 0
			cam.limit_right = 1600
			cam.limit_bottom = 1200

func _check_and_apply_level_state() -> void:
	var lvl := GameManager.current_level if GameManager != null else 1
	var wanje_allied := StoryManager != null and StoryManager.has_flag("wanje_allied")
	var is_level_2_or_above := lvl >= 2 or wanje_allied
	
	if is_level_2_or_above:
		_setup_level_2_state()
	else:
		_setup_level_1_state()

func _setup_level_1_state() -> void:
	_show_intro_banner("CHAPTER I", "Whispers in the Palms")
	if QuestManager != null:
		var q := QuestManager.get_active_quest()
		if q.is_empty():
			QuestManager.start_quest("quest_chapter_1")

func _setup_level_2_state() -> void:
	_show_intro_banner("CHAPTER II: LEVEL 2 & 3", "Colonial Shift & The Wanje Alliance")
	
	# Spawn colonial notices and runner near entry path
	_spawn_colonial_shift_elements()
	
	# Update Wanje as active quest partner
	var wanje := get_node_or_null("NPCs/NPCWanje") as NPCController
	if wanje != null:
		wanje.dialogue_id = "dialogue_wanje_level2"
		if wanje.interactable != null:
			wanje.interactable.prompt_message = "Plan Resistance Circuit"
			wanje.interactable.marker_type = "quest"
			
	# Start Level 2 Quest if Level 1 is done
	if QuestManager != null:
		var q := QuestManager.get_active_quest()
		if q.is_empty() or q.get("id", "") == "quest_chapter_1":
			QuestManager.start_quest("quest_level_2")
			
	# Relocate player to entry path facing colonial notices if at default spawn
	if player != null and player.global_position.distance_to(Vector2(430, 400)) < 40.0:
		player.global_position = Vector2(250, 470)
		
	# Update Council Fire status in Level 2+
	var council_fire := get_node_or_null("CouncilFire")
	if council_fire != null:
		var cf_interact: Interactable = council_fire.get_node_or_null("Interactable")
		if cf_interact != null:
			cf_interact.prompt_message = "Reflect at Council Fire"
			
	# Check if circuit is already active
	if StoryManager != null and StoryManager.has_flag("circuit_active"):
		_spawn_circuit_clusters()


func _spawn_colonial_shift_elements() -> void:
	if colonial_notice_node == null:
		colonial_notice_node = Node2D.new()
		colonial_notice_node.name = "ColonialNoticePost"
		colonial_notice_node.position = Vector2(180, 510)
		
		var spr := Sprite2D.new()
		var tex_path := "res://assets/environments/notice_board.png"
		if ResourceLoader.exists(tex_path):
			spr.texture = load(tex_path)
		colonial_notice_node.add_child(spr)
		
		var interact := Interactable.new()
		interact.prompt_message = "Inspect Colonial Notice"
		interact.marker_type = "quest"
		
		var col := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 48.0
		col.shape = shape
		interact.add_child(col)
		colonial_notice_node.add_child(interact)
		
		interact.interacted.connect(func(_p):
			if DialogueManager != null:
				DialogueManager.start_dialogue("dialogue_colonial_notice")
		)
		add_child(colonial_notice_node)
		
	if colonial_runner_node == null:
		colonial_runner_node = Node2D.new()
		colonial_runner_node.name = "ColonialRunnerNPC"
		colonial_runner_node.position = Vector2(270, 530)
		
		var spr := Sprite2D.new()
		var guard_tex := "res://assets/characters/colonial_guard.png"
		if ResourceLoader.exists(guard_tex):
			spr.texture = load(guard_tex)
			spr.hframes = 4
			spr.vframes = 4
			spr.frame = 0
		colonial_runner_node.add_child(spr)
		
		var interact := Interactable.new()
		interact.prompt_message = "Confront Colonial Runner"
		interact.marker_type = "talk"
		
		var col := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 48.0
		col.shape = shape
		interact.add_child(col)
		colonial_runner_node.add_child(interact)
		
		interact.interacted.connect(func(_p):
			if DialogueManager != null:
				DialogueManager.start_dialogue("dialogue_colonial_runner")
		)
		add_child(colonial_runner_node)

func _spawn_circuit_clusters() -> void:
	if clusters_spawned:
		return
	clusters_spawned = true
	
	if GameManager != null:
		GameManager.current_level = 4
		
	# 1. Bungale Cluster (Farmers in shamba)
	_spawn_cluster_delegate("ClusterBungale", Vector2(580, 800), "Rally Bungale Farmers", "dialogue_cluster_bungale", "res://assets/characters/villager_nyevu.png")
	
	# 2. Vitengeni Cluster (Elders near sacred baobab)
	_spawn_cluster_delegate("ClusterVitengeni", Vector2(960, 480), "Consult Vitengeni Council", "dialogue_cluster_vitengeni", "res://assets/characters/mzee_fondo.png")
	
	# 3. Kaya Fungo Delegates (At eastern sacred grove threshold)
	_spawn_cluster_delegate("ClusterKayaFungo", Vector2(1420, 540), "Assemble Kaya Delegates", "dialogue_cluster_kayafungo", "res://assets/characters/warrior_charo.png")

func _spawn_cluster_delegate(node_name: String, pos: Vector2, prompt: String, dialogue_id: String, sprite_path: String) -> void:
	var cluster_node := Node2D.new()
	cluster_node.name = node_name
	cluster_node.position = pos
	
	var spr := Sprite2D.new()
	if ResourceLoader.exists(sprite_path):
		spr.texture = load(sprite_path)
		spr.hframes = 4
		spr.vframes = 4
		spr.frame = 0
	cluster_node.add_child(spr)
	
	var interact := Interactable.new()
	interact.prompt_message = prompt
	interact.marker_type = "quest"
	
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 50.0
	col.shape = shape
	interact.add_child(col)
	cluster_node.add_child(interact)
	
	interact.interacted.connect(func(_p):
		if DialogueManager != null:
			DialogueManager.start_dialogue(dialogue_id)
	)
	add_child(cluster_node)

func _spawn_kaya_fungo_gateway() -> void:
	if gateway_spawned:
		return
	gateway_spawned = true
	
	var gate_node := Node2D.new()
	gate_node.name = "KayaFungoGateway"
	gate_node.position = Vector2(1500, 540)
	
	var visual := ColorRect.new()
	visual.offset_left = -30
	visual.offset_top = -40
	visual.offset_right = 30
	visual.offset_bottom = 40
	visual.color = Color(0.28, 0.44, 0.22, 0.8)
	gate_node.add_child(visual)
	
	var interact := Interactable.new()
	interact.prompt_message = "Enter Kaya Fungo (Level 5)"
	interact.marker_type = "quest"
	
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(80, 80)
	col.shape = shape
	interact.add_child(col)
	gate_node.add_child(interact)
	
	interact.interacted.connect(func(_p):
		if GameManager != null:
			GameManager.current_level = 5
		SceneManager.change_scene("res://scenes/environments/KifuduGathering.tscn")
	)
	add_child(gate_node)

func _on_dialogue_ended(dialogue_id: String) -> void:
	if dialogue_id == "dialogue_wanje_level2":
		_spawn_circuit_clusters()
	elif dialogue_id == "dialogue_cluster_kayafungo":
		_check_kifudu_readiness()

func _on_community_support_changed(new_val: int) -> void:
	if new_val >= 100:
		_check_kifudu_readiness()

func _check_kifudu_readiness() -> void:
	var support := StoryManager.community_support if StoryManager != null else 0
	var unlocked := StoryManager != null and StoryManager.has_flag("kifudu_unlocked")
	if support >= 100 or unlocked:
		_spawn_kaya_fungo_gateway()

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
		var tween := create_tween()
		tween.tween_property(chapter_intro_panel, "modulate:a", 1.0, 0.8)
		tween.tween_interval(2.5)
		tween.tween_property(chapter_intro_panel, "modulate:a", 0.0, 0.8)
		tween.tween_callback(func(): chapter_intro_panel.visible = false)

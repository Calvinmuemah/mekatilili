extends SceneTree

var ran_tests: bool = false

func _process(_delta: float) -> bool:
	if not ran_tests:
		ran_tests = true
		_run_all_tests()
	return true

func _run_all_tests() -> void:
	print("==================================================")
	print(" RUNNING MEKATILILI WA MENZA MVP TEST SUITE")
	print("==================================================")
	
	var passed := 0
	var failed := 0
	
	var game_manager = root.get_node_or_null("/root/GameManager")
	var save_manager = root.get_node_or_null("/root/SaveManager")
	var scene_manager = root.get_node_or_null("/root/SceneManager")
	var audio_manager = root.get_node_or_null("/root/AudioManager")
	var story_manager = root.get_node_or_null("/root/StoryManager")
	var dialogue_manager = root.get_node_or_null("/root/DialogueManager")
	var quest_manager = root.get_node_or_null("/root/QuestManager")
	var game_palette = root.get_node_or_null("/root/GamePalette")

	# TEST 1: Check Autoloads
	print("\n[TEST 1] Verifying Autoload Singletons...")
	if game_manager != null and save_manager != null and scene_manager != null and \
	   audio_manager != null and story_manager != null and dialogue_manager != null and \
	   quest_manager != null and game_palette != null:
		print("  -> PASS: All 8 core autoloads are present and active.")
		passed += 1
	else:
		push_error("  -> FAIL: Missing one or more autoloads.")
		failed += 1

	# TEST 2: Scene Instantiation
	print("\n[TEST 2] Verifying Scene Instantiations...")
	var scenes_to_test := [
		"res://scenes/main/SplashScreen.tscn",
		"res://scenes/main/MainMenu.tscn",
		"res://scenes/cinematics/IntroCinematic.tscn",
		"res://scenes/ui/HUD.tscn",
		"res://scenes/ui/ChapterComplete.tscn",
		"res://scenes/player/Player.tscn",
		"res://scenes/npcs/NPC.tscn",
		"res://scenes/environments/CollectibleItem.tscn",
		"res://scenes/environments/ShambaCrop.tscn",
		"res://scenes/environments/CouncilFire.tscn",
		"res://scenes/environments/VillageLevel.tscn"
	]
	var all_scenes_ok := true
	for sc_path in scenes_to_test:
		if not ResourceLoader.exists(sc_path):
			push_error("  -> FAIL: Scene does not exist: " + sc_path)
			all_scenes_ok = false
			continue
		var packed := load(sc_path) as PackedScene
		if packed == null:
			push_error("  -> FAIL: Could not load scene: " + sc_path)
			all_scenes_ok = false
			continue
		var inst := packed.instantiate()
		if inst == null:
			push_error("  -> FAIL: Could not instantiate: " + sc_path)
			all_scenes_ok = false
			continue
		inst.free()
	if all_scenes_ok:
		print("  -> PASS: All " + str(scenes_to_test.size()) + " game scenes instantiated cleanly.")
		passed += 1
	else:
		failed += 1

	# TEST 3: Dialogue System
	print("\n[TEST 3] Verifying Dialogue System...")
	dialogue_manager.load_all_dialogues()
	if dialogue_manager.dialogues_db.has("dialogue_nyevu") and \
	   dialogue_manager.dialogues_db.has("dialogue_charo") and \
	   dialogue_manager.dialogues_db.has("dialogue_mzee_fondo") and \
	   dialogue_manager.dialogues_db.has("dialogue_wanje"):
		dialogue_manager.start_dialogue("dialogue_nyevu")
		if dialogue_manager.is_active and dialogue_manager.current_node_id == "start":
			dialogue_manager.next_line()
			# At node_explanation: select choice 0
			dialogue_manager.select_choice(0)
			if story_manager.has_flag("nyevu_reassured"):
				print("  -> PASS: Dialogue loaded, navigated, choices processed, and flags set.")
				passed += 1
			else:
				push_error("  -> FAIL: Flag nyevu_reassured not set by choice.")
				failed += 1
		else:
			push_error("  -> FAIL: Dialogue start state invalid.")
			failed += 1
		dialogue_manager.end_dialogue()
	else:
		push_error("  -> FAIL: Missing required Chapter 1 dialogues.")
		failed += 1

	# TEST 4: Quest System & Objectives
	print("\n[TEST 4] Verifying Quest Progression...")
	quest_manager.load_all_quests()
	var q_started: bool = quest_manager.start_quest("quest_chapter_1")
	if q_started and quest_manager.active_quest_id == "quest_chapter_1":
		var init_obj: String = quest_manager.get_current_objective_text()
		quest_manager.advance_active_objective() # Objective 0 complete
		var second_obj: String = quest_manager.get_current_objective_text()
		if init_obj != second_obj:
			print("  -> PASS: Quest started and active objective advanced.")
			passed += 1
		else:
			push_error("  -> FAIL: Objective description did not advance.")
			failed += 1
	else:
		push_error("  -> FAIL: Quest chapter 1 failed to start.")
		failed += 1

	# TEST 5: Collectibles & Journal
	print("\n[TEST 5] Verifying Collectibles & Journal...")
	var initial_col_count: int = story_manager.collectibles.size()
	story_manager.add_collectible("test_item", "Test Relic", "A sacred artifact", "", "Historical lore")
	if story_manager.collectibles.size() == initial_col_count + 1 and \
	   story_manager.journal_data.has("collectibles"):
		print("  -> PASS: Collectible registered and Journal updated.")
		passed += 1
	else:
		push_error("  -> FAIL: Collectible or Journal registration failed.")
		failed += 1

	# TEST 6: Save and Load System
	print("\n[TEST 6] Verifying Save / Load System...")
	story_manager.set_flag("test_save_flag", true)
	var save_ok: bool = save_manager.save_game({"chapter": 1})
	if save_ok and save_manager.has_save_file():
		var summary: Dictionary = save_manager.get_save_data_summary()
		if summary.get("version", 0) == 1 and summary.has("story_flags"):
			print("  -> PASS: Versioned JSON save created and schema validated.")
			passed += 1
		else:
			push_error("  -> FAIL: Save data schema missing expected fields.")
			failed += 1
	else:
		push_error("  -> FAIL: SaveManager failed to write file.")
		failed += 1

	# Clean up test save
	save_manager.delete_save()

	# TEST 7: Settings and Audio Bus Controls
	print("\n[TEST 7] Verifying Audio and Settings...")
	save_manager.current_settings["master_volume"] = 0.75
	save_manager.apply_settings()
	if is_equal_approx(audio_manager.master_volume, 0.75):
		print("  -> PASS: Audio settings applied accurately.")
		passed += 1
	else:
		push_error("  -> FAIL: Master volume not updated.")
		failed += 1

	print("\n==================================================")
	print(" TEST RESULTS: " + str(passed) + " PASSED, " + str(failed) + " FAILED")
	print("==================================================")
	
	if failed == 0:
		print("ALL TESTS PASSED SUCCESSFULLY! PROJECT IS VERIFIED.")
	else:
		push_error("SOME TESTS FAILED.")

extends SceneTree

var ran_tests: bool = false

func _process(_delta: float) -> bool:
	if not ran_tests:
		ran_tests = true
		_run_all_tests()
	return true

func _run_all_tests() -> void:
	print("==================================================")
	print(" RUNNING MEKATILILI WA MENZA VERIFICATION TEST SUITE")
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
	var api_client = root.get_node_or_null("/root/ApiClient")
	var network_manager = root.get_node_or_null("/root/NetworkManager")
	var auth_manager = root.get_node_or_null("/root/AuthManager")
	var sync_manager = root.get_node_or_null("/root/SyncManager")
	var content_sync_manager = root.get_node_or_null("/root/ContentSyncManager")
	var telemetry_manager = root.get_node_or_null("/root/TelemetryManager")

	# TEST 1: Check Autoloads
	print("\n[TEST 1] Verifying Autoload Singletons...")
	if game_manager != null and save_manager != null and scene_manager != null and \
	   audio_manager != null and story_manager != null and dialogue_manager != null and \
	   quest_manager != null and game_palette != null and api_client != null and \
	   network_manager != null and auth_manager != null and sync_manager != null and \
	   content_sync_manager != null and telemetry_manager != null:
		print("  -> PASS: All 14 core & integration autoloads are present and active.")
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
		"res://scenes/ui/AuthDialog.tscn",
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

	# TEST 6: Save and Load System with Version 2 Metadata
	print("\n[TEST 6] Verifying Save / Load System & Metadata...")
	story_manager.set_flag("test_save_flag", true)
	var save_ok: bool = save_manager.save_game({"chapter": 1})
	if save_ok and save_manager.has_save_file():
		var summary: Dictionary = save_manager.get_save_data_summary()
		if summary.get("version", 0) == 2 and summary.has("story_flags") and \
		   summary.has("sync_status") and summary.has("device_id") and summary.has("last_modified_at"):
			print("  -> PASS: Version 2 JSON save created with authoritative offline metadata.")
			passed += 1
		else:
			push_error("  -> FAIL: Save data schema missing expected fields or version mismatch.")
			failed += 1
	else:
		push_error("  -> FAIL: SaveManager failed to write file.")
		failed += 1

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

	# TEST 8: NetworkManager & ApiClient Offline Mode
	print("\n[TEST 8] Verifying NetworkManager & Offline State Machine...")
	network_manager.set_offline_override(true)
	if not network_manager.is_online():
		network_manager.set_offline_override(false)
		print("  -> PASS: Offline-first override and state transition verified.")
		passed += 1
	else:
		push_error("  -> FAIL: NetworkManager did not respect offline override.")
		failed += 1

	# TEST 9: ContentSyncManager Bundle Validation & Safety
	print("\n[TEST 9] Verifying Content Bundle Validation & Safety...")
	var test_valid_bundle := {
		"version": "1.0.1",
		"chapters": [{"id": "chapter_1"}],
		"quests": [{"id": "q1"}],
		"npcs": [{"id": "npc1"}],
		"dialogues": [{"id": "d1"}],
		"collectibles": [],
		"journal": []
	}
	var test_corrupted_bundle := {
		"version": "bad",
		"chapters": []
	}
	var is_valid_ok: bool = content_sync_manager.validate_content_bundle(test_valid_bundle)
	var is_corrupt_rejected: bool = not content_sync_manager.validate_content_bundle(test_corrupted_bundle)
	if is_valid_ok and is_corrupt_rejected:
		print("  -> PASS: Content validator accepts valid bundles and rejects invalid schemas.")
		passed += 1
	else:
		push_error("  -> FAIL: Content validator behavior incorrect.")
		failed += 1

	# TEST 10: Telemetry Queueing & Offline Persistence
	print("\n[TEST 10] Verifying Telemetry Queueing & Local Persistence...")
	var initial_q_size: int = telemetry_manager.event_queue.size()
	telemetry_manager.record_event("QUEST_STARTED", {"quest": "test_quest"}, "chapter_1", "test_quest")
	if telemetry_manager.event_queue.size() >= initial_q_size + 1 and \
	   FileAccess.file_exists(telemetry_manager.QUEUE_FILE_PATH):
		print("  -> PASS: Telemetry event queued and written to local queue file.")
		passed += 1
	else:
		push_error("  -> FAIL: Telemetry queue failed to persist event.")
		failed += 1

	# TEST 11: Local Save Backup & Conflict Safety
	print("\n[TEST 11] Verifying Save Backup & Conflict Safety...")
	var backup_ok: bool = save_manager.create_backup()
	if backup_ok and save_manager.has_backup_file():
		var restore_ok: bool = save_manager.restore_from_backup()
		if restore_ok:
			print("  -> PASS: Local save backup and restore operate safely without data loss.")
			passed += 1
		else:
			push_error("  -> FAIL: Save restore from backup failed.")
			failed += 1
	else:
		push_error("  -> FAIL: Save backup creation failed.")
		failed += 1

	# Clean up test save and backup
	save_manager.delete_save()
	if FileAccess.file_exists(save_manager.BACKUP_FILE_PATH):
		DirAccess.remove_absolute(save_manager.BACKUP_FILE_PATH)

	print("\n==================================================")
	print(" TEST RESULTS: " + str(passed) + " PASSED, " + str(failed) + " FAILED")
	print("==================================================")
	
	if failed == 0:
		print("ALL TESTS PASSED SUCCESSFULLY! PROJECT IS VERIFIED.")
	else:
		push_error("SOME TESTS FAILED.")

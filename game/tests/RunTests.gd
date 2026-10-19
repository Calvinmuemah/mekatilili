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
		"res://scenes/environments/VillageLevel.tscn",
		"res://scenes/characters/ColonialSentry.tscn",
		"res://scenes/environments/KifuduGathering.tscn",
		"res://scenes/environments/ColonialStation.tscn",
		"res://scenes/cinematics/ArrestSequence.tscn",
		"res://scenes/environments/KisiiPrison.tscn",
		"res://scenes/environments/WildernessTrek.tscn"
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

	# TEST 3: Dialogue System & Support Points
	print("\n[TEST 3] Verifying Dialogue System...")
	story_manager.reset_state()
	dialogue_manager.reset_state()
	dialogue_manager.load_all_dialogues()
	quest_manager.load_all_quests()
	quest_manager.start_quest("quest_chapter_1")
	
	if dialogue_manager.dialogues_db.has("dialogue_nyevu") and \
	   dialogue_manager.dialogues_db.has("dialogue_charo") and \
	   dialogue_manager.dialogues_db.has("dialogue_mzee_fondo") and \
	   dialogue_manager.dialogues_db.has("dialogue_wanje"):
		dialogue_manager.start_dialogue("dialogue_nyevu")
		if dialogue_manager.is_active and dialogue_manager.current_node_id == "start":
			dialogue_manager.next_line()
			# At node_explanation: select choice 0 (should add +15 support from JSON)
			dialogue_manager.select_choice(0)
			
			var support_ok: bool = story_manager.community_support == 15
			var flag_ok: bool = story_manager.has_flag("nyevu_reassured")
			
			# Continue through node_resolve to node_finish (which completes objective 0)
			dialogue_manager.next_line()
			
			var active_q: Dictionary = quest_manager.get_active_quest()
			var obj0_completed: bool = false
			if not active_q.is_empty():
				var objs: Array = active_q.get("objectives", [])
				if objs.size() > 0:
					obj0_completed = objs[0].get("completed", false)
			
			if support_ok and flag_ok and obj0_completed:
				print("  -> PASS: Dialogue loaded, choices processed, community support awarded (" + str(story_manager.community_support) + "%), and objective completed.")
				passed += 1
			else:
				push_error("  -> FAIL: Dialogue event processing failed. support_ok=" + str(support_ok) + " flag_ok=" + str(flag_ok) + " obj0_completed=" + str(obj0_completed))
				failed += 1
		else:
			push_error("  -> FAIL: Dialogue start state invalid.")
			failed += 1
		dialogue_manager.end_dialogue()
	else:
		push_error("  -> FAIL: Missing required Chapter 1 dialogues.")
		failed += 1

	# TEST 4: Quest System & Out-of-Order Objectives
	print("\n[TEST 4] Verifying Quest Progression...")
	quest_manager.load_all_quests()
	var q_started: bool = quest_manager.start_quest("quest_chapter_1")
	if q_started and quest_manager.active_quest_id == "quest_chapter_1":
		var q_data: Dictionary = quest_manager.get_active_quest()
		var objs: Array = q_data.get("objectives", [])
		var init_desc: String = objs[0].get("description", "")
		
		# Test out-of-order: Harvest cassava first (objective 1) before speaking to Nyevu (objective 0)
		quest_manager.complete_objective("quest_chapter_1", 1)
		
		# Objective 0 is still incomplete, so current objective must still point to objective 0
		var current_text: String = quest_manager.get_current_objective_text()
		var order_safe_1: bool = (current_text == init_desc)
		
		# Now complete objective 0: next incomplete objective should skip 1 and jump to 2 (Mzee Fondo)
		quest_manager.complete_objective("quest_chapter_1", 0)
		var after_obj0_text: String = quest_manager.get_current_objective_text()
		var order_safe_2: bool = (after_obj0_text == objs[2].get("description", ""))
		
		if order_safe_1 and order_safe_2:
			print("  -> PASS: Out-of-order quest objective progression operates robustly.")
			passed += 1
		else:
			push_error("  -> FAIL: Quest out-of-order handling failed. order_safe_1=" + str(order_safe_1) + " order_safe_2=" + str(order_safe_2))
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

	# TEST 12: Accessibility and Voiceover System
	print("\n[TEST 12] Verifying Accessibility & Voiceover System...")
	if save_manager.current_settings.get("voiceover_enabled", false) == true and \
	   audio_manager.has_method("speak_text") and audio_manager.has_method("stop_voiceover"):
		audio_manager.speak_text("Testing voiceover output", "Elder Mzee Fondo")
		audio_manager.stop_voiceover()
		print("  -> PASS: Voiceover enabled by default and TTS invocation validated.")
		passed += 1
	else:
		push_error("  -> FAIL: Voiceover not configured or default is not ON.")
		failed += 1

	# TEST 13: Levels 2-11 Quests and Dialogues Pipeline
	print("\n[TEST 13] Verifying Levels 2-11 Quests & Dialogues Pipeline...")
	quest_manager.load_all_quests()
	dialogue_manager.load_all_dialogues()
	var quests_ok: bool = quest_manager.quests_db.has("quest_level_2") and \
	                      quest_manager.quests_db.has("quest_level_4") and \
	                      quest_manager.quests_db.has("quest_level_6") and \
	                      quest_manager.quests_db.has("quest_level_8") and \
	                      quest_manager.quests_db.has("quest_level_9") and \
	                      quest_manager.quests_db.has("quest_level_10") and \
	                      quest_manager.quests_db.has("quest_level_11")
	var dialogues_ok: bool = dialogue_manager.dialogues_db.has("dialogue_colonial_notice") and \
	                         dialogue_manager.dialogues_db.has("dialogue_colonial_runner") and \
	                         dialogue_manager.dialogues_db.has("dialogue_wanje_level2") and \
	                         dialogue_manager.dialogues_db.has("dialogue_cluster_bungale") and \
	                         dialogue_manager.dialogues_db.has("dialogue_cluster_vitengeni") and \
	                         dialogue_manager.dialogues_db.has("dialogue_cluster_kayafungo") and \
	                         dialogue_manager.dialogues_db.has("dialogue_kifudu_speech") and \
	                         dialogue_manager.dialogues_db.has("dialogue_arthur_champion") and \
	                         dialogue_manager.dialogues_db.has("dialogue_arrest") and \
	                         dialogue_manager.dialogues_db.has("dialogue_kisii_wanje") and \
	                         dialogue_manager.dialogues_db.has("dialogue_kisii_breakout") and \
	                         dialogue_manager.dialogues_db.has("dialogue_wilderness_return")
	if quests_ok and dialogues_ok:
		print("  -> PASS: All Chapter 2 & Chapter 3 (Levels 2-11) quests and branching dialogue trees verified.")
		passed += 1
	else:
		push_error("  -> FAIL: Missing Chapter 2 or Chapter 3 quest or dialogue definitions.")
		failed += 1


	# TEST 14: Community Support Counter & Circuit Progression
	print("\n[TEST 14] Verifying Community Support Counter & Circuit Progression...")
	story_manager.community_support = 0
	story_manager.add_community_support(35)
	var sup1_ok: bool = (int(story_manager.community_support) == 35)
	story_manager.add_community_support(35)
	var sup2_ok: bool = (int(story_manager.community_support) == 70)
	story_manager.add_community_support(30)
	var sup3_ok: bool = (int(story_manager.community_support) == 100)
	quest_manager.start_quest("quest_level_4")
	quest_manager.advance_active_objective() # obj 0
	quest_manager.advance_active_objective() # obj 1
	quest_manager.advance_active_objective() # obj 2 (completes quest)
	var q4_state = quest_manager.quests_db["quest_level_4"]["state"]
	if sup1_ok and sup2_ok and sup3_ok and q4_state == quest_manager.QuestState.COMPLETED:
		print("  -> PASS: Community support counter (0-100%) and circuit quests validated.")
		passed += 1
	else:
		push_error("  -> FAIL: Community support calculation or quest advancement failed.")
		failed += 1

	# TEST 15: Colonial Station & Hen Chase Progression
	print("\n[TEST 15] Verifying Colonial Station & Hen Chase Progression...")
	quest_manager.start_quest("quest_level_6")
	quest_manager.complete_objective("quest_level_6", 0) # approach Champion
	quest_manager.complete_objective("quest_level_6", 1) # release hen
	quest_manager.complete_objective("quest_level_6", 2) # escape south gate
	var q6_state = quest_manager.quests_db["quest_level_6"]["state"]
	var champion_pitch_ok: bool = audio_manager._get_character_pitch("Arthur Champion") == 0.78
	var sentry_pitch_ok: bool = audio_manager._get_character_pitch("Colonial Sentry") == 0.82
	if q6_state == quest_manager.QuestState.COMPLETED and champion_pitch_ok and sentry_pitch_ok:
		print("  -> PASS: Hen release, compound chase, and colonial audio profiles verified.")
		passed += 1
	else:
		push_error("  -> FAIL: Colonial station chase or audio validation failed.")
		failed += 1

	# TEST 16: UI Dynamic Text Layout & Cultural Emblems
	print("\n[TEST 16] Verifying UI Dynamic Text Layout & Cultural Emblems...")
	var test_hud: Node = load("res://scenes/ui/HUD.tscn").instantiate()
	var test_obj_panel: Control = test_hud.get_node("TopRight/VBox/ObjectivePanel")
	var test_desc_lbl: Label = test_hud.get_node("TopRight/VBox/ObjectivePanel/Margin/VBox/DescLabel")
	var test_shield: TextureRect = test_hud.get_node("TopLeft/Panel/HBox/ShieldIcon")
	var obj_dynamic_ok: bool = (test_obj_panel.custom_minimum_size.y == 0 and \
	                            test_desc_lbl.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART and \
	                            test_shield != null and test_shield.texture != null)

	var test_dlg: Node = load("res://scenes/ui/DialogueBox.tscn").instantiate()
	var test_dlg_panel: Panel = test_dlg.get_node("Panel")
	var test_text_lbl: RichTextLabel = test_dlg.get_node("Panel/HBox/ContentVBox/TextLabel")
	var test_choices: VBoxContainer = test_dlg.get_node("Panel/HBox/ContentVBox/ChoicesContainer")
	var dlg_layout_ok: bool = (test_dlg_panel.custom_minimum_size.y >= 140 and \
	                           test_text_lbl.get_parent() == test_choices.get_parent() and \
	                           test_text_lbl.get_index() < test_choices.get_index())

	var test_vl: Node = load("res://scenes/environments/VillageLevel.tscn").instantiate()
	var vl_emblems_ok: bool = (test_vl.has_node("CulturalEmblems") and \
	                           test_vl.get_node("CulturalEmblems").has_node("VigangoVillageEntry") and \
	                           test_vl.get_node("CulturalEmblems").has_node("BannerCouncilNorth"))

	var test_kg: Node = load("res://scenes/environments/KifuduGathering.tscn").instantiate()
	var kg_emblems_ok: bool = (test_kg.has_node("CulturalEmblems") and \
	                           test_kg.get_node("CulturalEmblems").has_node("VigangoLeft") and \
	                           test_kg.get_node("CulturalEmblems").has_node("GiriamaBannerNorthLeft"))

	test_hud.free()
	test_dlg.free()
	test_vl.free()
	test_kg.free()

	if obj_dynamic_ok and dlg_layout_ok and vl_emblems_ok and kg_emblems_ok:
		print("  -> PASS: Dynamic objective panel, separated dialogue choices, and cultural emblems verified.")
		passed += 1
	else:
		push_error("  -> FAIL: Dynamic UI text layout or cultural emblems check failed. obj=" + str(obj_dynamic_ok) + " dlg=" + str(dlg_layout_ok) + " vl=" + str(vl_emblems_ok) + " kg=" + str(kg_emblems_ok))
		failed += 1

	# TEST 17: Prompt Cleanup & Chapter Complete Progression
	print("\n[TEST 17] Verifying Prompt Cleanup & Chapter Complete Progression...")
	# 1. Prompt Cleanup & Dynamic Stretching check
	var hud_test: Node = load("res://scenes/ui/HUD.tscn").instantiate()
	root.add_child(hud_test)
	hud_test.touch_controls.visible = true
	hud_test.set_interaction_prompt("[E / TAP] Address the Assembly")
	var prompt_visible_on_touch: bool = hud_test.prompt_panel.visible
	var prompt_clean_text: bool = (hud_test.prompt_label.text == "Address the Assembly")
	
	# Test stretching with long prompt
	hud_test.set_interaction_prompt("[E / TAP] Release the mother hen and chicks into Arthur Champion veranda!")
	var bottom_c: Control = hud_test.get_node_or_null("BottomCenter") as Control
	var card_width: float = (bottom_c.offset_right - bottom_c.offset_left) if bottom_c != null else 0.0
	var prompt_stretched_ok: bool = (card_width >= 400.0)
	hud_test.queue_free()

	# 2. Chapter Complete Card & Transition
	var cc_test: Node = load("res://scenes/ui/ChapterComplete.tscn").instantiate()
	root.add_child(cc_test)
	var cc_proc_ok: bool = (cc_test.process_mode == Node.PROCESS_MODE_ALWAYS)
	var margin_node: MarginContainer = cc_test.get_node_or_null("PanelContainer/MarginContainer")
	var margin_ok: bool = (margin_node != null and margin_node.get_theme_constant("margin_left") >= 28)
	var cc_title_wrap: bool = (cc_test.title_label.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART)
	var cc_chapter_wrap: bool = (cc_test.chapter_label.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART)
	
	# Simulate Chapter 2 completion and Continue button press
	paused = true
	game_manager.current_level = 8
	cc_test._populate_summary()
	cc_test._on_continue_pressed()
	
	var unpaused_ok: bool = (not paused)
	var save_summary: Dictionary = save_manager.get_save_data_summary()
	var save_recorded_ok: bool = (save_summary.get("chapter", 0) == 2 or save_summary.get("chapter", 0) == 3 or save_summary.get("chapter_2_completed", false) == true)
	cc_test.queue_free()

	# Also test Chapter 3 / Act III completion screen
	var cc3_test: Node = load("res://scenes/ui/ChapterComplete.tscn").instantiate()
	root.add_child(cc3_test)
	game_manager.current_level = 12
	cc3_test._populate_summary()
	var ch3_title_ok: bool = ("ACT III" in cc3_test.title_label.text or "CHAPTER III" in cc3_test.title_label.text)
	cc3_test.queue_free()

	if prompt_visible_on_touch and prompt_clean_text and prompt_stretched_ok and cc_proc_ok and margin_ok and cc_title_wrap and cc_chapter_wrap and unpaused_ok and save_recorded_ok and ch3_title_ok:
		print("  -> PASS: Persistent interaction prompt, clean words, dynamic card stretching, and Chapter 2 & 3 progression validated.")
		passed += 1
	else:
		push_error("  -> FAIL: Test 17 failed. prompt_visible=" + str(prompt_visible_on_touch) + " prompt_clean=" + str(prompt_clean_text) + " stretched=" + str(prompt_stretched_ok) + " cc_proc=" + str(cc_proc_ok) + " margin=" + str(margin_ok) + " unpaused=" + str(unpaused_ok) + " save=" + str(save_recorded_ok) + " ch3_ok=" + str(ch3_title_ok))
		failed += 1

	print("\n[TEST 18] Verifying Wilderness Trek Interaction, DialogueBox Choices, and Banner Contrast...")
	# 1. StoryManager set_community_support
	story_manager.set_community_support(10)
	var support_set_ok: bool = (story_manager.community_support == 10)

	# 2. Wilderness Trek scene & Water Spring Interaction
	var wt_scene: Node = load("res://scenes/environments/WildernessTrek.tscn").instantiate()
	root.add_child(wt_scene)
	var water_connected_ok: bool = wt_scene.water_interactable.interacted.is_connected(wt_scene._on_water_interacted)
	# Trigger water interaction
	wt_scene._on_water_interacted(wt_scene.player)
	var water_collected_ok: bool = (wt_scene.water_collected == true)
	var endurance_boosted_ok: bool = (story_manager.community_support == 40)
	var quest_11_obj0_done: bool = quest_manager.quests_db.has("quest_level_11") and quest_manager.quests_db["quest_level_11"]["objectives"][0]["completed"] == true
	wt_scene.queue_free()

	# 3. DialogueBox Choice Expansion and Text Visibility
	var dlg_test: DialogueBox = load("res://scenes/ui/DialogueBox.tscn").instantiate()
	root.add_child(dlg_test)
	var mock_node := {
		"speaker": "Captain Phillips",
		"text": "Mekatilili wa Menza! You and Wanje are under arrest.",
		"choices": [
			{"text": "You come with rifles because you fear words of truth.", "next": ""},
			{"text": "The Giriama people will not yield.", "next": ""}
		]
	}
	dlg_test._on_dialogue_node_reached(mock_node)
	var panel_expanded_ok: bool = (dlg_test.panel.offset_top <= -300.0)
	var text_min_size_ok: bool = (dlg_test.text_label.custom_minimum_size.y >= 60.0)
	var text_visible_ok: bool = (dlg_test.text_label.visible_characters == -1)
	dlg_test.queue_free()

	# 4. TouchControls ActionBtn Prompt Formatting
	var touch_test: TouchControls = load("res://scenes/ui/TouchControls.tscn").instantiate()
	root.add_child(touch_test)
	touch_test.set_prompt("Replenish Calabash at Spring")
	var prompt_water_ok: bool = (touch_test.action_btn.text == "💧 REPLENISH")
	touch_test.set_prompt("Forage Rift Valley Herbs")
	var prompt_herb_ok: bool = (touch_test.action_btn.text == "🌿 FORAGE")
	touch_test.set_prompt("Slip Past Railway Scouts")
	var prompt_scout_ok: bool = (touch_test.action_btn.text == "👣 EVADE")
	touch_test.queue_free()

	# 5. Banner Toast Contrast, Dynamic Stretching, and Auto-wrap
	var hud_b_test: HUD = load("res://scenes/ui/HUD.tscn").instantiate()
	root.add_child(hud_b_test)
	var banner_title_wrap: bool = (hud_b_test.banner_title.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART)
	var banner_desc_wrap: bool = (hud_b_test.banner_desc.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART)
	hud_b_test.show_collectible_banner("OBJECTIVE UPDATED", "Walk around the village, speak with the elders, and help a fellow villager.")
	var banner_shown_ok: bool = (hud_b_test.banner_panel.visible == true)
	var banner_stretched_height: float = (hud_b_test.top_center.offset_bottom - hud_b_test.top_center.offset_top)
	var banner_height_ok: bool = (banner_stretched_height >= 90.0)
	hud_b_test.queue_free()

	if support_set_ok and water_connected_ok and water_collected_ok and endurance_boosted_ok and quest_11_obj0_done and panel_expanded_ok and text_min_size_ok and text_visible_ok and prompt_water_ok and prompt_herb_ok and prompt_scout_ok and banner_title_wrap and banner_desc_wrap and banner_shown_ok and banner_height_ok:
		print("  -> PASS: Wilderness trek water replenishment, DialogueBox choices expansion, TouchControls prompt verbs, and dynamic Banner card validated.")
		passed += 1
	else:
		push_error("  -> FAIL: Test 18 failed. support=" + str(support_set_ok) + " connected=" + str(water_connected_ok) + " collected=" + str(water_collected_ok) + " endurance=" + str(endurance_boosted_ok) + " quest=" + str(quest_11_obj0_done) + " panel_exp=" + str(panel_expanded_ok) + " text_min=" + str(text_min_size_ok) + " text_vis=" + str(text_visible_ok) + " p_water=" + str(prompt_water_ok) + " p_herb=" + str(prompt_herb_ok) + " p_scout=" + str(prompt_scout_ok) + " banner_wrap=" + str(banner_desc_wrap) + " banner_shown=" + str(banner_shown_ok))
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

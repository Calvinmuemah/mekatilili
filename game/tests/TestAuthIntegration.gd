extends SceneTree

var ran_tests: bool = false

func _process(_delta: float) -> bool:
	if not ran_tests:
		ran_tests = true
		_run_test()
	return false

func _run_test() -> void:
	print("\n--- RUNNING AUTH INTEGRATION TEST ---")
	
	# 1. Test AuthDialog scene instantiation & node resolution
	var scene: PackedScene = load("res://scenes/ui/AuthDialog.tscn")
	assert(scene != null, "AuthDialog.tscn failed to load")
	var dialog: Control = scene.instantiate()
	root.add_child(dialog)
	
	# Check essential nodes
	var reg_container: Control = dialog.get_node("Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/RegisterContainer")
	assert(reg_container != null, "RegisterContainer could not be found")
	var reg_submit: Button = reg_container.get_node("SubmitBtn")
	assert(reg_submit != null, "RegisterContainer SubmitBtn not found")
	print("  -> PASS: AuthDialog instantiated and Register button found with text: '", reg_submit.text, "'")
	
	var login_container: Control = dialog.get_node("Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/LoginContainer")
	assert(login_container != null, "LoginContainer could not be found")
	var login_submit: Button = login_container.get_node("SubmitBtn")
	assert(login_submit != null, "LoginContainer SubmitBtn not found")
	print("  -> PASS: AuthDialog Login button found with text: '", login_submit.text, "'")
	
	# 2. Test live Registration with the API
	var auth_mgr = root.get_node_or_null("AuthManager")
	assert(auth_mgr != null, "AuthManager autoload not found")
	
	var rand_suffix := str(randi() % 90000 + 10000)
	var test_user := "hero_" + rand_suffix
	var test_email := "hero_" + rand_suffix + "@mekatilili.test"
	var test_pass := "StrongPass123!"
	
	print("  -> Testing registration for: ", test_user, " / ", test_email)
	var reg_res: Dictionary = await auth_mgr.register(test_email, test_user, test_pass, "Hero " + rand_suffix)
	print("  -> Registration result: success=", reg_res.get("success", false), " error=", reg_res.get("error", ""))
	assert(reg_res.get("success", false) == true, "Registration failed: " + str(reg_res.get("error", "")))
	assert(auth_mgr.is_authenticated() == true, "AuthManager should be authenticated after register")
	assert(auth_mgr.get_access_token() != "", "Access token must not be empty after register")
	print("  -> PASS: Registration succeeded and token stored: ", auth_mgr.get_access_token().substr(0, 20), "...")
	
	# 3. Test Logout
	auth_mgr.logout()
	assert(auth_mgr.is_authenticated() == false, "AuthManager should not be authenticated after logout")
	print("  -> PASS: Logout cleared session.")
	
	# 4. Test Sign In with the newly registered user
	print("  -> Testing Sign In with username: ", test_user)
	var login_res: Dictionary = await auth_mgr.login(test_user, test_pass)
	print("  -> Login result: success=", login_res.get("success", false), " error=", login_res.get("error", ""))
	assert(login_res.get("success", false) == true, "Login failed: " + str(login_res.get("error", "")))
	assert(auth_mgr.is_authenticated() == true, "AuthManager should be authenticated after login")
	assert(auth_mgr.get_access_token() != "", "Access token must not be empty after login")
	print("  -> PASS: Sign In succeeded and token stored.")
	
	# Cleanup session
	auth_mgr.logout()
	dialog.queue_free()
	
	print("\nALL AUTH INTEGRATION TESTS PASSED!\n")
	quit(0)

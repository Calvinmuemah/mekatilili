class_name AuthDialog
extends Control

signal auth_completed(success: bool)

@onready var panel: Panel = $Panel
@onready var close_btn: Button = $Panel/MarginContainer/VBox/HeaderHBox/CloseBtn
@onready var title_lbl: Label = $Panel/MarginContainer/VBox/HeaderHBox/Title
@onready var notice_lbl: Label = $Panel/MarginContainer/VBox/Notice

# Tabs
@onready var tab_login_btn: Button = $Panel/MarginContainer/VBox/TabButtons/LoginTabBtn
@onready var tab_register_btn: Button = $Panel/MarginContainer/VBox/TabButtons/RegisterTabBtn
@onready var tab_guest_btn: Button = $Panel/MarginContainer/VBox/TabButtons/GuestTabBtn
@onready var tab_profile_btn: Button = $Panel/MarginContainer/VBox/TabButtons/ProfileTabBtn

# Containers
@onready var login_container: VBoxContainer = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/LoginContainer
@onready var register_container: VBoxContainer = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/RegisterContainer
@onready var guest_container: VBoxContainer = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/GuestContainer
@onready var profile_container: VBoxContainer = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/ProfileContainer

# Login fields
@onready var login_user_input: LineEdit = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/LoginContainer/UserEdit
@onready var login_pass_input: LineEdit = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/LoginContainer/PassEdit
@onready var login_submit_btn: Button = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/LoginContainer/SubmitBtn
@onready var login_status_lbl: Label = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/LoginContainer/StatusLbl
@onready var switch_to_register_btn: Button = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/LoginContainer/SwitchToRegisterBtn

# Register fields
@onready var reg_email_input: LineEdit = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/RegisterContainer/Grid/EmailCol/EmailEdit
@onready var reg_user_input: LineEdit = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/RegisterContainer/Grid/UserCol/UserEdit
@onready var reg_pass_input: LineEdit = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/RegisterContainer/Grid/PassCol/PassEdit
@onready var reg_name_input: LineEdit = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/RegisterContainer/Grid/NameCol/NameEdit
@onready var reg_submit_btn: Button = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/RegisterContainer/SubmitBtn
@onready var reg_status_lbl: Label = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/RegisterContainer/StatusLbl
@onready var switch_to_login_btn: Button = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/RegisterContainer/SwitchToLoginBtn

# Guest
@onready var guest_submit_btn: Button = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/GuestContainer/ContinueGuestBtn

# Profile
@onready var profile_info_lbl: Label = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/ProfileContainer/ProfileInfo
@onready var profile_status_lbl: Label = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/ProfileContainer/ProfileStatus
@onready var profile_sync_btn: Button = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/ProfileContainer/ProfileBtnHBox/SyncBtn
@onready var profile_logout_btn: Button = $Panel/MarginContainer/VBox/ScrollContainer/FormsContainer/ProfileContainer/ProfileBtnHBox/LogoutBtn

var current_tab_index: int = 0

func _get_auth_mgr() -> Node:
	return get_node_or_null("/root/AuthManager")

func _get_save_mgr() -> Node:
	return get_node_or_null("/root/SaveManager")

func _get_audio_mgr() -> Node:
	return get_node_or_null("/root/AudioManager")

func _get_sync_mgr() -> Node:
	return get_node_or_null("/root/SyncManager")

func _ready() -> void:
	_style_ui()
	_refresh_auth_view()
	
	close_btn.pressed.connect(func(): visible = false)
	tab_login_btn.pressed.connect(func(): _switch_tab(0))
	tab_register_btn.pressed.connect(func(): _switch_tab(1))
	tab_guest_btn.pressed.connect(func(): _switch_tab(2))
	tab_profile_btn.pressed.connect(func(): _switch_tab(3))
	
	login_submit_btn.pressed.connect(_on_login_submit)
	reg_submit_btn.pressed.connect(_on_register_submit)
	guest_submit_btn.pressed.connect(_on_guest_continue)
	
	switch_to_register_btn.pressed.connect(func(): _switch_tab(1))
	switch_to_login_btn.pressed.connect(func(): _switch_tab(0))
	
	profile_sync_btn.pressed.connect(_on_profile_sync)
	profile_logout_btn.pressed.connect(_on_profile_logout)
	
	# Mobile/Desktop text submission navigation
	login_user_input.text_submitted.connect(func(_t): login_pass_input.grab_focus())
	login_pass_input.text_submitted.connect(func(_t): _on_login_submit())
	
	reg_email_input.text_submitted.connect(func(_t): reg_user_input.grab_focus())
	reg_user_input.text_submitted.connect(func(_t): reg_pass_input.grab_focus())
	reg_pass_input.text_submitted.connect(func(_t): reg_name_input.grab_focus())
	reg_name_input.text_submitted.connect(func(_t): _on_register_submit())

	var save_mgr := _get_save_mgr()
	if save_mgr != null and save_mgr.has_signal("settings_changed"):
		save_mgr.settings_changed.connect(_style_ui)
		
	var auth_mgr := _get_auth_mgr()
	if auth_mgr != null:
		auth_mgr.auth_state_changed.connect(func(_logged_in, _user): _refresh_auth_view())

func _refresh_auth_view() -> void:
	var auth_mgr := _get_auth_mgr()
	var is_auth := false
	if auth_mgr != null:
		is_auth = auth_mgr.is_authenticated()
		
	tab_profile_btn.visible = is_auth
	if is_auth:
		var user: Dictionary = auth_mgr.get_current_user()
		var dname: String = user.get("display_name", user.get("username", "Explorer"))
		var email: String = user.get("email", "")
		profile_info_lbl.text = "Connected as: %s (%s)\nCloud Synchronization: Active" % [dname, email]
		_switch_tab(3)
	else:
		_switch_tab(0)

func _style_ui() -> void:
	var style := GamePalette.create_panel_style(GamePalette.COLOR_SAND, GamePalette.COLOR_WARM_GOLD, 12, 3)
	panel.add_theme_stylebox_override("panel", style)
	
	# Header & Notice typography
	if title_lbl != null:
		title_lbl.add_theme_color_override("font_color", Color("#8C3518")) # Terracotta header
		title_lbl.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(17))
	if notice_lbl != null:
		notice_lbl.add_theme_color_override("font_color", GamePalette.COLOR_CHARCOAL) # Charcoal on Sand
		notice_lbl.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(12))
	
	# Action buttons styling
	GamePalette.apply_button_theme(login_submit_btn, GamePalette.COLOR_TERRACOTTA, GamePalette.FONT_SIZE_BODY)
	GamePalette.apply_button_theme(reg_submit_btn, GamePalette.COLOR_TERRACOTTA, GamePalette.FONT_SIZE_BODY)
	GamePalette.apply_button_theme(guest_submit_btn, GamePalette.COLOR_FOREST_GREEN, GamePalette.FONT_SIZE_BODY)
	GamePalette.apply_button_theme(profile_sync_btn, GamePalette.COLOR_FOREST_GREEN, GamePalette.FONT_SIZE_BODY)
	GamePalette.apply_button_theme(profile_logout_btn, GamePalette.COLOR_TERRACOTTA, GamePalette.FONT_SIZE_BODY)
	GamePalette.apply_button_theme(close_btn, GamePalette.COLOR_DEEP_EARTH, GamePalette.FONT_SIZE_BODY)
	
	# Switch link buttons
	for link_btn in [switch_to_register_btn, switch_to_login_btn]:
		if link_btn != null:
			link_btn.add_theme_color_override("font_color", Color("#8C3518"))
			link_btn.add_theme_color_override("font_hover_color", GamePalette.COLOR_CHARCOAL)
			link_btn.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(12))
	
	# Style all line edits with Deep Earth background and Ivory text
	var all_inputs := [login_user_input, login_pass_input, reg_email_input, reg_user_input, reg_pass_input, reg_name_input]
	for input in all_inputs:
		_style_line_edit(input)
		
	# Ensure all sub-labels in form containers have Charcoal text for AAA contrast on Sand
	var forms := [login_container, register_container, guest_container, profile_container]
	for form in forms:
		if form != null:
			_style_labels_in_tree(form)
					
	if login_status_lbl != null:
		login_status_lbl.add_theme_color_override("font_color", Color("#B85C38"))
	if reg_status_lbl != null:
		reg_status_lbl.add_theme_color_override("font_color", Color("#B85C38"))
	if profile_status_lbl != null:
		profile_status_lbl.add_theme_color_override("font_color", GamePalette.COLOR_FOREST_GREEN)

func _style_labels_in_tree(node: Node) -> void:
	if node is Label:
		var lbl := node as Label
		if lbl != login_status_lbl and lbl != reg_status_lbl and lbl != profile_status_lbl:
			lbl.add_theme_color_override("font_color", GamePalette.COLOR_CHARCOAL)
			lbl.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(13))
	for child in node.get_children():
		_style_labels_in_tree(child)

func _style_line_edit(edit: LineEdit) -> void:
	if edit == null:
		return
	var sb_normal := StyleBoxFlat.new()
	sb_normal.bg_color = GamePalette.COLOR_DEEP_EARTH # #3B2416
	sb_normal.border_color = GamePalette.COLOR_WARM_GOLD # #D9A441
	sb_normal.set_border_width_all(2)
	sb_normal.set_corner_radius_all(6)
	sb_normal.content_margin_left = 12
	sb_normal.content_margin_right = 12
	sb_normal.content_margin_top = 8
	sb_normal.content_margin_bottom = 8
	
	var sb_focus := sb_normal.duplicate() as StyleBoxFlat
	sb_focus.border_color = Color("#FFE299") # Luminous gold on focus
	sb_focus.set_border_width_all(2)
	
	edit.add_theme_stylebox_override("normal", sb_normal)
	edit.add_theme_stylebox_override("focus", sb_focus)
	edit.add_theme_color_override("font_color", GamePalette.COLOR_IVORY) # Pure Ivory #F7F0DE
	edit.add_theme_color_override("font_placeholder_color", Color(0.91, 0.83, 0.66, 0.6)) # Sand @ 60%
	edit.add_theme_color_override("font_selected_color", GamePalette.COLOR_CHARCOAL)
	edit.add_theme_color_override("selection_color", GamePalette.COLOR_WARM_GOLD)
	edit.add_theme_color_override("caret_color", GamePalette.COLOR_WARM_GOLD)
	edit.add_theme_font_size_override("font_size", GamePalette.get_scaled_font_size(GamePalette.FONT_SIZE_BODY))

func _switch_tab(tab_idx: int) -> void:
	current_tab_index = tab_idx
	login_container.visible = tab_idx == 0
	register_container.visible = tab_idx == 1
	guest_container.visible = tab_idx == 2
	profile_container.visible = tab_idx == 3
	
	GamePalette.apply_button_theme(tab_login_btn, GamePalette.COLOR_TERRACOTTA if tab_idx == 0 else GamePalette.COLOR_DEEP_EARTH, GamePalette.FONT_SIZE_CAPTION + 1)
	GamePalette.apply_button_theme(tab_register_btn, GamePalette.COLOR_TERRACOTTA if tab_idx == 1 else GamePalette.COLOR_DEEP_EARTH, GamePalette.FONT_SIZE_CAPTION + 1)
	GamePalette.apply_button_theme(tab_guest_btn, GamePalette.COLOR_FOREST_GREEN if tab_idx == 2 else GamePalette.COLOR_DEEP_EARTH, GamePalette.FONT_SIZE_CAPTION + 1)
	if tab_profile_btn.visible:
		GamePalette.apply_button_theme(tab_profile_btn, GamePalette.COLOR_FOREST_GREEN if tab_idx == 3 else GamePalette.COLOR_DEEP_EARTH, GamePalette.FONT_SIZE_CAPTION + 1)

	# Clear status labels on tab change
	login_status_lbl.text = ""
	reg_status_lbl.text = ""

func _show_status(lbl: Label, msg: String, is_success: bool = false, is_loading: bool = false) -> void:
	if lbl == null:
		return
	lbl.text = msg
	if is_loading:
		lbl.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
	elif is_success:
		lbl.add_theme_color_override("font_color", GamePalette.COLOR_FOREST_GREEN)
	else:
		lbl.add_theme_color_override("font_color", Color("#B85C38"))

func _on_login_submit() -> void:
	var user := login_user_input.text.strip_edges()
	var pass_str := login_pass_input.text
	
	if user == "":
		_show_status(login_status_lbl, "Please enter your username or email.", false)
		login_user_input.grab_focus()
		return
	if pass_str == "":
		_show_status(login_status_lbl, "Please enter your password.", false)
		login_pass_input.grab_focus()
		return
		
	_show_status(login_status_lbl, "Signing in...", false, true)
	login_submit_btn.disabled = true
	
	var auth_mgr := _get_auth_mgr()
	var audio_mgr := _get_audio_mgr()
	if auth_mgr != null:
		var res: Dictionary = await auth_mgr.login(user, pass_str)
		login_submit_btn.disabled = false
		if res.get("success", false):
			var user_info: Dictionary = res.get("user", {})
			var name_str: String = user_info.get("display_name", user_info.get("username", user))
			_show_status(login_status_lbl, "Signed in! Welcome back, " + name_str, true)
			if audio_mgr != null:
				audio_mgr.play_sfx("sfx_quest_complete")
			await get_tree().create_timer(0.6).timeout
			visible = false
			auth_completed.emit(true)
		else:
			var err: String = res.get("error", "Sign in failed")
			_show_status(login_status_lbl, err, false)
			if audio_mgr != null:
				audio_mgr.play_sfx("sfx_click")
	else:
		login_submit_btn.disabled = false
		_show_status(login_status_lbl, "Auth service not available.", false)

func _on_register_submit() -> void:
	var email := reg_email_input.text.strip_edges()
	var user := reg_user_input.text.strip_edges()
	var pass_str := reg_pass_input.text
	var dname := reg_name_input.text.strip_edges()
	
	if email == "" or not ("@" in email and "." in email):
		_show_status(reg_status_lbl, "Please enter a valid email address.", false)
		reg_email_input.grab_focus()
		return
	if user.length() < 3:
		_show_status(reg_status_lbl, "Username must be at least 3 characters long.", false)
		reg_user_input.grab_focus()
		return
	if pass_str.length() < 6:
		_show_status(reg_status_lbl, "Password must be at least 6 characters long.", false)
		reg_pass_input.grab_focus()
		return
		
	_show_status(reg_status_lbl, "Creating account...", false, true)
	reg_submit_btn.disabled = true
	
	var auth_mgr := _get_auth_mgr()
	var audio_mgr := _get_audio_mgr()
	if auth_mgr != null:
		var res: Dictionary = await auth_mgr.register(email, user, pass_str, dname)
		reg_submit_btn.disabled = false
		if res.get("success", false):
			var user_info: Dictionary = res.get("user", {})
			var name_str: String = user_info.get("display_name", user_info.get("username", user))
			_show_status(reg_status_lbl, "Account created! Welcome, " + name_str, true)
			if audio_mgr != null:
				audio_mgr.play_sfx("sfx_quest_complete")
			await get_tree().create_timer(0.6).timeout
			visible = false
			auth_completed.emit(true)
		else:
			var err: String = res.get("error", "Registration failed")
			_show_status(reg_status_lbl, err, false)
			if audio_mgr != null:
				audio_mgr.play_sfx("sfx_click")
	else:
		reg_submit_btn.disabled = false
		_show_status(reg_status_lbl, "Auth service not available.", false)

func _on_guest_continue() -> void:
	var audio_mgr := _get_audio_mgr()
	if audio_mgr != null:
		audio_mgr.play_sfx("sfx_click")
	var auth_mgr := _get_auth_mgr()
	if auth_mgr != null:
		auth_mgr.continue_as_guest()
	visible = false
	auth_completed.emit(true)

func _on_profile_sync() -> void:
	var audio_mgr := _get_audio_mgr()
	if audio_mgr != null:
		audio_mgr.play_sfx("sfx_click")
	profile_status_lbl.text = "Syncing local saves to cloud..."
	profile_status_lbl.add_theme_color_override("font_color", GamePalette.COLOR_WARM_GOLD)
	var sync_mgr := _get_sync_mgr()
	if sync_mgr != null:
		sync_mgr.sync_progress()
		await get_tree().create_timer(0.8).timeout
		profile_status_lbl.text = "✦ Cloud synchronization complete!"
		profile_status_lbl.add_theme_color_override("font_color", GamePalette.COLOR_FOREST_GREEN)
	else:
		profile_status_lbl.text = "Sync service unavailable."

func _on_profile_logout() -> void:
	var audio_mgr := _get_audio_mgr()
	if audio_mgr != null:
		audio_mgr.play_sfx("sfx_click")
	var auth_mgr := _get_auth_mgr()
	if auth_mgr != null:
		auth_mgr.logout()
	_refresh_auth_view()

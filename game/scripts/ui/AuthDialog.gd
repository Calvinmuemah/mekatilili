class_name AuthDialog
extends Control

signal auth_completed(success: bool)

@onready var panel: Panel = $Panel
@onready var close_btn: Button = $Panel/CloseBtn

# Tabs
@onready var tab_login_btn: Button = $Panel/VBox/TabButtons/LoginTabBtn
@onready var tab_register_btn: Button = $Panel/VBox/TabButtons/RegisterTabBtn
@onready var tab_guest_btn: Button = $Panel/VBox/TabButtons/GuestTabBtn

# Containers
@onready var login_container: VBoxContainer = $Panel/VBox/LoginContainer
@onready var register_container: VBoxContainer = $Panel/VBox/RegisterContainer
@onready var guest_container: VBoxContainer = $Panel/VBox/GuestContainer

# Login fields
@onready var login_user_input: LineEdit = $Panel/VBox/LoginContainer/UserEdit
@onready var login_pass_input: LineEdit = $Panel/VBox/LoginContainer/PassEdit
@onready var login_submit_btn: Button = $Panel/VBox/LoginContainer/SubmitBtn
@onready var login_status_lbl: Label = $Panel/VBox/LoginContainer/StatusLbl

# Register fields
@onready var reg_email_input: LineEdit = $Panel/VBox/RegisterContainer/EmailEdit
@onready var reg_user_input: LineEdit = $Panel/VBox/RegisterContainer/UserEdit
@onready var reg_pass_input: LineEdit = $Panel/VBox/RegisterContainer/PassEdit
@onready var reg_name_input: LineEdit = $Panel/VBox/RegisterContainer/NameEdit
@onready var reg_submit_btn: Button = $Panel/VBox/RegisterContainer/SubmitBtn
@onready var reg_status_lbl: Label = $Panel/VBox/RegisterContainer/StatusLbl

# Guest
@onready var guest_submit_btn: Button = $Panel/VBox/GuestContainer/ContinueGuestBtn

func _ready() -> void:
	_style_ui()
	_switch_tab(0)
	
	close_btn.pressed.connect(func(): visible = false)
	tab_login_btn.pressed.connect(func(): _switch_tab(0))
	tab_register_btn.pressed.connect(func(): _switch_tab(1))
	tab_guest_btn.pressed.connect(func(): _switch_tab(2))
	
	login_submit_btn.pressed.connect(_on_login_submit)
	reg_submit_btn.pressed.connect(_on_register_submit)
	guest_submit_btn.pressed.connect(_on_guest_continue)

func _style_ui() -> void:
	var style := GamePalette.create_panel_style(GamePalette.COLOR_SAND, GamePalette.COLOR_WARM_GOLD, 12, 3)
	panel.add_theme_stylebox_override("panel", style)
	
	GamePalette.apply_button_theme(login_submit_btn, GamePalette.COLOR_TERRACOTTA)
	GamePalette.apply_button_theme(reg_submit_btn, GamePalette.COLOR_TERRACOTTA)
	GamePalette.apply_button_theme(guest_submit_btn, GamePalette.COLOR_FOREST_GREEN)
	GamePalette.apply_button_theme(close_btn, GamePalette.COLOR_CHARCOAL)

func _switch_tab(tab_idx: int) -> void:
	login_container.visible = tab_idx == 0
	register_container.visible = tab_idx == 1
	guest_container.visible = tab_idx == 2
	
	GamePalette.apply_button_theme(tab_login_btn, GamePalette.COLOR_TERRACOTTA if tab_idx == 0 else GamePalette.COLOR_DEEP_EARTH)
	GamePalette.apply_button_theme(tab_register_btn, GamePalette.COLOR_TERRACOTTA if tab_idx == 1 else GamePalette.COLOR_DEEP_EARTH)
	GamePalette.apply_button_theme(tab_guest_btn, GamePalette.COLOR_FOREST_GREEN if tab_idx == 2 else GamePalette.COLOR_DEEP_EARTH)

func _on_login_submit() -> void:
	var user := login_user_input.text.strip_edges()
	var pass_str := login_pass_input.text
	
	if user == "" or pass_str == "":
		login_status_lbl.text = "Please enter your username and password."
		return
		
	login_status_lbl.text = "Signing in..."
	login_submit_btn.disabled = true
	
	if AuthManager != null:
		var res: Dictionary = await AuthManager.login(user, pass_str)
		login_submit_btn.disabled = false
		if res.get("success", false):
			login_status_lbl.text = "Success!"
			visible = false
			auth_completed.emit(true)
		else:
			login_status_lbl.text = res.get("error", "Sign in failed")
	else:
		login_submit_btn.disabled = false

func _on_register_submit() -> void:
	var email := reg_email_input.text.strip_edges()
	var user := reg_user_input.text.strip_edges()
	var pass_str := reg_pass_input.text
	var dname := reg_name_input.text.strip_edges()
	
	if email == "" or user == "" or pass_str.length() < 6:
		reg_status_lbl.text = "Valid email, username, and 6+ character password required."
		return
		
	reg_status_lbl.text = "Creating account..."
	reg_submit_btn.disabled = true
	
	if AuthManager != null:
		var res: Dictionary = await AuthManager.register(email, user, pass_str, dname)
		reg_submit_btn.disabled = false
		if res.get("success", false):
			reg_status_lbl.text = "Account created!"
			visible = false
			auth_completed.emit(true)
		else:
			reg_status_lbl.text = res.get("error", "Registration failed")
	else:
		reg_submit_btn.disabled = false

func _on_guest_continue() -> void:
	if AuthManager != null:
		AuthManager.continue_as_guest()
	visible = false
	auth_completed.emit(true)

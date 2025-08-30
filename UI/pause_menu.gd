extends Control

@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var settings_menu: Control = $SettingsMenu
@onready var back_button: Button = $SettingsMenu/BackButton

func _ready() -> void:
	# Connect button signals with error checking
	if resume_button:
		resume_button.pressed.connect(_on_resume_button_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)

	# Initially hide the pause menu and settings
	visible = false
	if settings_menu:
		settings_menu.visible = false
	
	# Grab focus on resume button when menu opens
	if resume_button:
		resume_button.grab_focus()

func _input(event: InputEvent) -> void:
	# Toggle pause with Escape key
	if event.is_action_pressed("ui_cancel") and (not settings_menu or not settings_menu.visible):
		if not get_tree().paused:
			pause_game()
		else:
			resume_game()

func pause_game() -> void:
	Engine.time_scale = 0
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if resume_button:
		resume_button.grab_focus()

func back_button_handler() -> void:
	settings_menu.visible = false
	$VBoxContainer.visible = true

func resume_game() -> void:
	Engine.time_scale = 1
	visible = false
	if settings_menu:
		settings_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Adjust based on your game

func _on_back_button_pressed() -> void:
	back_button_handler()

func _on_resume_button_pressed() -> void:
	resume_game()

func _on_settings_button_pressed() -> void:
	if settings_menu:
		settings_menu.visible = true
		$VBoxContainer.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_quit_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().quit(0) ## before this save game

func _on_settings_menu_closed() -> void:
	if settings_menu:
		settings_menu.visible = false
	$VBoxContainer.visible = true
	if resume_button:
		resume_button.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta: float) -> void:
	if not visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Adjust based on your game

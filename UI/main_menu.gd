extends Control

@onready var main_menu = $VBoxContainer
@onready var settings_menu = $SettingsMenu

## main menu
@onready var play_button = $VBoxContainer/PlayButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var quit_button = $VBoxContainer/QuitButton
## settings menu
@onready var music_slider = $SettingsMenu/VBoxContainer/MusicSlider
@onready var sfx_slider = $SettingsMenu/VBoxContainer/SFXSlider
@onready var back_button = $SettingsMenu/BackButton
@onready var animation_player = $AnimationPlayer

var config = ConfigFile.new()
const SAVE_PATH = "user://settings.cfg"

func _ready():
	# Load saved settings
	load_settings()
	
	# Connect button signals
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	
	# Ensure main menu is visible, settings hidden
	main_menu.show()
	settings_menu.hide()
	
	# Play initial animation
	#animation_player.play("menu_fade_in")

func _on_play_button_pressed():
	# Flashy transition to game scene (placeholder)
	#animation_player.play("flashy_transition")
	#await animation_player.animation_finished
	get_tree().change_scene_to_file("res://Levels/DevMap.tscn") # Replace with your game scene path

func _on_settings_button_pressed():
	# Flashy transition to settings
	#animation_player.play("slide_to_settings")
	#await animation_player.animation_finished
	main_menu.hide()
	settings_menu.show()

func _on_quit_button_pressed():
	# Flashy exit animation
	#animation_player.play("flashy_exit")
	#await animation_player.animation_finished
	get_tree().quit()

func _on_back_button_pressed():
	# Save settings when leaving settings menu
	save_settings()
	# Transition back to main menu
	#animation_player.play("slide_to_main")
	#await animation_player.animation_finished
	settings_menu.hide()
	main_menu.show()

func _on_music_slider_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_slider_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func save_settings():
	config.set_value("audio", "music_volume", music_slider.value)
	config.set_value("audio", "sfx_volume", sfx_slider.value)
	config.save(SAVE_PATH)

func load_settings():
	var err = config.load(SAVE_PATH)
	if err == OK:
		music_slider.value = config.get_value("audio", "music_volume", 0.5)
		sfx_slider.value = config.get_value("audio", "sfx_volume", 0.5)
	else:
		# Default values
		music_slider.value = 0.5
		sfx_slider.value = 0.5

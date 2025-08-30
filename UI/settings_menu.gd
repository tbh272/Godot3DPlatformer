extends Control

@onready var music_slider = $VBoxContainer/MusicSlider
@onready var sfx_slider = $VBoxContainer/SFXSlider
@onready var back_button = $BackButton

var config = ConfigFile.new()
const SAVE_PATH = "user://settings.cfg"

signal back_pressed

func _ready():
	load_settings()
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	back_button.pressed.connect(_on_back_button_pressed)

func _on_music_slider_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_slider_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_back_button_pressed():
	save_settings()
	back_pressed.emit()

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
		music_slider.value = 0.5
		sfx_slider.value = 0.5

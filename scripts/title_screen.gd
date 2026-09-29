extends Control

## Title screen: Start begins a fresh march.

const MAIN_SCENE := "res://scenes/main/Main.tscn"

@onready var start_button: TextureButton = %StartButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	start_button.grab_focus()

func _on_start_pressed() -> void:
	Party.reset()
	get_tree().change_scene_to_file(MAIN_SCENE)

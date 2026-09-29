extends Control
class_name EndScreen

var title_text: String = ""
var body_text: String = ""

@onready var title_label: Label = %TitleLabel
@onready var body_label: Label = %BodyLabel
@onready var restart_button: TextureButton = %RestartButton

func _ready() -> void:
	title_label.text = title_text
	body_label.text = body_text
	restart_button.pressed.connect(_on_restart_pressed)

func _on_restart_pressed() -> void:
	Party.reset()
	get_tree().reload_current_scene()

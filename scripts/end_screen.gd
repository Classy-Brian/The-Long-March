extends Control
class_name EndScreen

var title_text: String = ""
var body_text: String = ""

@onready var title_label: Label = %TitleLabel
@onready var body_label: Label = %BodyLabel

func _ready() -> void:
	title_label.text = title_text
	body_label.text = body_text

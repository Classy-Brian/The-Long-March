extends Control
class_name PlaceholderDecision

signal decision_made

@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_button_pressed)

func _on_continue_button_pressed() -> void:
	print("decision made")
	decision_made.emit()

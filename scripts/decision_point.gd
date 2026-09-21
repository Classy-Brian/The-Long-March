extends Control
class_name DecisionPoint

@export var event: DecisionEvent

@onready var prompt_label: Label = %PromptLabel
@onready var choice_a_button: Button = %ChoiceAButton
@onready var choice_b_button: Button = %ChoiceBButton

func _ready() -> void:
	if event == null:
		push_warning("DecisionPoint has no event assigned.")
		return
	prompt_label.text = event.prompt_text
	choice_a_button.text = event.a_text
	choice_b_button.text = event.b_text

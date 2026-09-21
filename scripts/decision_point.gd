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
	choice_a_button.pressed.connect(_on_choice_a_button_pressed)
	choice_b_button.pressed.connect(_on_choice_b_button_pressed)

func _on_choice_a_button_pressed() -> void:
	if _roll(event.a_success_chance):
		print(event.a_success_result)
		_apply(event.a_success_health, event.a_success_hydration, event.a_success_morale)
	else:
		print(event.a_failure_result)
		_apply(event.a_failure_health, event.a_failure_hydration, event.a_failure_morale)

func _on_choice_b_button_pressed() -> void:
	if _roll(event.b_success_chance):
		print(event.b_success_result)
		_apply(event.b_success_health, event.b_success_hydration, event.b_success_morale)
	else:
		print(event.b_failure_result)
		_apply(event.b_failure_health, event.b_failure_hydration, event.b_failure_morale)

func _apply(health: float, hydration: float, morale: float) -> void:
	var soldier: Soldier = Party.get_main_soldier()
	soldier.apply_stat_delta("health", health)
	soldier.apply_stat_delta("hydration", hydration)
	soldier.apply_stat_delta("morale", morale)
	print("  Health: ", soldier.health, "  Hydration: ", soldier.hydration, "  Morale: ", soldier.morale)

func _roll(chance: float) -> bool:
	return randf() * 100.0 < chance

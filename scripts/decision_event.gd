extends Resource
class_name DecisionEvent

## One decision-point event. Each real event is a filled-in .tres file
## using this as its blueprint - same pattern as Soldier.

@export_multiline var prompt_text: String = ""

@export_group("Choice A")
@export var a_text: String = ""
@export_range(0, 100) var a_success_chance: float = 100.0
@export_multiline var a_success_result: String = ""
@export var a_success_health: float = 0.0
@export var a_success_hydration: float = 0.0
@export var a_success_morale: float = 0.0
@export_multiline var a_failure_result: String = ""
@export var a_failure_health: float = 0.0
@export var a_failure_hydration: float = 0.0
@export var a_failure_morale: float = 0.0

@export_group("Choice B")
@export var b_text: String = ""
@export_range(0, 100) var b_success_chance: float = 100.0
@export_multiline var b_success_result: String = ""
@export var b_success_health: float = 0.0
@export var b_success_hydration: float = 0.0
@export var b_success_morale: float = 0.0
@export_multiline var b_failure_result: String = ""
@export var b_failure_health: float = 0.0
@export var b_failure_hydration: float = 0.0
@export var b_failure_morale: float = 0.0

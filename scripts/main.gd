extends Node2D

const PACE_SCENE: PackedScene = preload("res://scenes/relentless_pace/RelentlessPace.tscn")
const DECISION_SCENE: PackedScene = preload("res://scenes/decision_point/DecisionPoint.tscn")
const TEST_EVENT: DecisionEvent = preload("res://events/puddle_water.tres")

@onready var ui_layer: CanvasLayer = %UILayer

var current_scene: Node = null

func _ready() -> void:
	_start_pace()

func _start_pace() -> void:
	var pace: RelentlessPace = PACE_SCENE.instantiate()
	pace.segment_completed.connect(_on_pace_completed)
	_show_screen(pace)

func _start_decision() -> void:
	var decision: DecisionPoint = DECISION_SCENE.instantiate()
	decision.event = TEST_EVENT
	decision.decision_made.connect(_on_decision_made)
	_show_screen(decision)

func _show_screen(new_scene: Node) -> void:
	if current_scene:
		current_scene.queue_free()
	current_scene = new_scene
	ui_layer.add_child(new_scene)

func _on_pace_completed(success: bool) -> void:
	print("Pace finished. Success: ", success)
	_start_decision()

func _on_decision_made() -> void:
	print("Back to marching.")
	_start_pace()

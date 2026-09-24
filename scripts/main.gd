extends Node2D

const PACE_SCENE: PackedScene = preload("res://scenes/relentless_pace/RelentlessPace.tscn")
const DECISION_SCENE: PackedScene = preload("res://scenes/decision_point/DecisionPoint.tscn")
const END_SCENE: PackedScene = preload("res://scenes/ending/EndScreen.tscn")

@export var events: Array[DecisionEvent] = []
@export var pace_lines: Array[String] = []

@onready var parallax_layers: Array[Parallax2D] = [%Mountain, %BackBG, %BG, %Foreground]
@onready var ui_layer: CanvasLayer = %UILayer
@onready var health_label: Label = %HealthLabel
@onready var hydration_label: Label = %HydrationLabel
@onready var morale_label: Label = %MoraleLabel
@onready var sergeant: AnimatedSprite2D = %Sergeant

var current_scene: Node = null
var _event_index: int = 0
var _march_over: bool = false

func _ready() -> void:
	Party.get_main_soldier().changed.connect(_update_stats)
	Party.soldier_died.connect(_on_soldier_died)
	_update_stats()
	_start_pace()
	_set_marching(true)

func _start_pace() -> void:
	var pace: RelentlessPace = PACE_SCENE.instantiate()
	if not pace_lines.is_empty():
		pace.target_text = pace_lines[_event_index % pace_lines.size()]
	pace.segment_completed.connect(_on_pace_completed)
	_show_screen(pace)

func _start_decision() -> void:
	var decision: DecisionPoint = DECISION_SCENE.instantiate()
	decision.event = events[_event_index]
	_event_index += 1
	decision.decision_made.connect(_on_decision_made)
	_show_screen(decision)

func _show_screen(new_scene: Node) -> void:
	if current_scene:
		current_scene.queue_free()
	current_scene = new_scene
	ui_layer.add_child(new_scene)

func _on_pace_completed(success: bool) -> void:
	if _march_over:
		return
	print("Pace finished. Success: ", success)
	_start_decision()
	_set_marching(false)

func _on_decision_made() -> void:
	if _march_over:
		return
	
	if _event_index >= events.size():
		_end_march()
	else:
		_start_pace()
		_set_marching(true)

func _set_marching(marching: bool) -> void:
	for layer in parallax_layers:
		layer.process_mode = Node.PROCESS_MODE_INHERIT if marching else Node.PROCESS_MODE_DISABLED
	if marching:
		sergeant.play("walk")
	else:
		sergeant.stop()
		sergeant.frame = 0

func _end_march() -> void:
	_show_end("The column halts.", "You are still on your feet when the guards call the end of the day's march.")

func _update_stats() -> void:
	var soldier: Soldier = Party.get_main_soldier()
	health_label.text = "Health: %d" % soldier.health
	hydration_label.text = "Hydration: %d" % soldier.hydration
	morale_label.text = "Morale: %d" % soldier.morale

func _on_soldier_died(soldier: Soldier) -> void:
	if not soldier.is_main:
		return
	_show_end("The march goes on without you.", soldier.death_cause)

func _show_end(title: String, body: String) -> void:
	if _march_over:
		return
	_march_over = true
	var ending: EndScreen = END_SCENE.instantiate()
	ending.title_text = title
	ending.body_text = body
	_set_marching(false)
	_show_screen(ending)

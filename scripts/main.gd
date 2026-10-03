extends Node2D

const PACE_SCENE: PackedScene = preload("res://scenes/relentless_pace/RelentlessPace.tscn")
const DECISION_SCENE: PackedScene = preload("res://scenes/decision_point/DecisionPoint.tscn")
const END_SCENE: PackedScene = preload("res://scenes/ending/EndScreen.tscn")
const DEATH_SCENE: PackedScene = preload("res://scenes/death/DeathCutscene.tscn")

@export var events: Array[DecisionEvent] = []
@export var pace_lines: Array[String] = []

@onready var parallax_layers: Array[Parallax2D] = [%Mountain, %BackBG, %Trees, %BG, %Foreground]
@onready var ui_layer: CanvasLayer = %UILayer
@onready var health_label: Label = %HealthLabel
@onready var hydration_label: Label = %HydrationLabel
@onready var morale_label: Label = %MoraleLabel
@onready var health_icon: StatIcon = %HealthIcon
@onready var hydration_icon: StatIcon = %HydrationIcon
@onready var morale_icon: StatIcon = %MoraleIcon
@onready var walkers: Array[AnimatedSprite2D] = [%Guard, %Private1, %Private2, %Sergeant]

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
	Sfx.set_footsteps(marching)
	for layer in parallax_layers:
		layer.process_mode = Node.PROCESS_MODE_INHERIT if marching else Node.PROCESS_MODE_DISABLED
	for walker in walkers:
		if marching:
			walker.play("walk")
		else:
			walker.stop()
			walker.frame = 0

func _end_march() -> void:
	_show_end("The column halts.", "You are still on your feet when the guards call the end of the day's march.")

func _update_stats() -> void:
	var soldier: Soldier = Party.get_main_soldier()
	health_label.text = "%d" % ceili(soldier.health)
	hydration_label.text = "%d" % ceili(soldier.hydration)
	morale_label.text = "%d" % ceili(soldier.morale)
	health_icon.show_value(soldier.health)
	hydration_icon.show_value(soldier.hydration)
	morale_icon.show_value(soldier.morale)

func _on_soldier_died(soldier: Soldier) -> void:
	if not soldier.is_main or _march_over:
		return
	_march_over = true
	_set_marching(false)
	var cutscene: DeathCutscene = DEATH_SCENE.instantiate()
	cutscene.cause = soldier.death_cause
	cutscene.finished.connect(_present_end.bind("The march goes on without you.", soldier.death_cause))
	_show_screen(cutscene)

func _show_end(title: String, body: String) -> void:
	if _march_over:
		return
	_march_over = true
	_set_marching(false)
	_present_end(title, body)

func _present_end(title: String, body: String) -> void:
	var ending: EndScreen = END_SCENE.instantiate()
	ending.title_text = title
	ending.body_text = body
	_show_screen(ending)

## DEBUG ONLY - test keys, ignored in release exports (Export With Debug off).
## F1 guard  F2 dysentery  F3 dehydration  F4 truck  F5 wounds  F6 all stats -20
func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var soldier: Soldier = Party.get_main_soldier()
	match event.keycode:
		KEY_F1:
			soldier.apply_stat_delta("health", -999.0, "Beaten for falling behind.")
		KEY_F2:
			soldier.apply_stat_delta("health", -999.0, "Dysentery, from the water in the road.")
		KEY_F3:
			soldier.apply_stat_delta("hydration", -999.0)
		KEY_F4:
			soldier.apply_stat_delta("health", -999.0, "Run over by a truck.")
		KEY_F5:
			soldier.apply_stat_delta("health", -999.0, "Collapsed on the road.")
		KEY_F6:
			for stat in ["health", "hydration", "morale"]:
				soldier.apply_stat_delta(stat, -20.0, "Collapsed on the road.")

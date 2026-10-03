extends Control
class_name RelentlessPace

## First pass at the "Relentless Pace" typing segment. The player must type
## out `target_text` before `time_limit` runs out. Falling behind (a wrong
## keystroke) drains the main soldier's Health. This is a scaffold
## tuning (drain rate, time limit, difficulty scaling)

signal segment_completed(success: bool)

@export var target_text: String = "Keep moving. Do not fall behind."
@export var time_limit: float = 20.0
@export var health_penalty_per_mistake: float = 2.0
## Marching under the sun: Hydration drains every second you're still typing.
@export var hydration_drain_per_second: float = 0.5
## Running out of time means you fell behind the column.
@export var timeout_health_penalty: float = 10.0

@onready var target_label: Label = %TargetLabel
@onready var input_field: LineEdit = %InputField
@onready var timer_bar: ProgressBar = %TimerBar

var _time_remaining: float = 0.0
var _finished: bool = false

func _ready() -> void:
	_time_remaining = time_limit
	target_label.text = target_text
	input_field.text = ""
	input_field.text_changed.connect(_on_text_changed)
	input_field.grab_focus()

func _process(delta: float) -> void:
	if _finished:
		return
	_time_remaining -= delta
	var ratio: float = maxf(_time_remaining, 0.0) / time_limit
	timer_bar.value = ratio * 100.0
	# Last 30%: the bar turns blood red.
	timer_bar.modulate = Color(1, 1, 1) if ratio > 0.3 else Color(2.5, 0.4, 0.4)
	var main: Soldier = Party.get_main_soldier()
	if main:
		main.apply_stat_delta("hydration", -hydration_drain_per_second * delta)
	if _time_remaining <= 0.0:
		if main:
			main.apply_stat_delta("health", -timeout_health_penalty, "Beaten for falling behind.")
		_finish(false)

func _on_text_changed(new_text: String) -> void:
	if _finished:
		return
	if target_text.begins_with(new_text):
		# Typewriter key: random pitch so no two keys sound the same.
		Sfx.play("type", -3.0, randf_range(0.9, 1.25))
	else:
		# Wrong key: same click, pitched way down - a dull thunk.
		Sfx.play("type", 0.0, 0.55)
	if new_text == target_text:
		_finish(true)
	elif not target_text.begins_with(new_text):
		_apply_mistake_penalty()

func _apply_mistake_penalty() -> void:
	var main: Soldier = Party.get_main_soldier()
	if main:
		main.apply_stat_delta("health", -health_penalty_per_mistake, "Beaten for falling behind.")

func _finish(success: bool) -> void:
	_finished = true
	segment_completed.emit(success)

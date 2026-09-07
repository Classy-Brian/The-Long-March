extends Control
class_name RelentlessPace

## First pass at the "Relentless Pace" typing segment. The player must type
## out `target_text` before `time_limit` runs out. Falling behind (a wrong
## keystroke) drains the main soldier's Stamina. This is a scaffold -
## tuning (drain rate, time limit, difficulty scaling) is not finalized;

signal segment_completed(success: bool)

@export var target_text: String = "Keep moving. Do not fall behind."
@export var time_limit: float = 20.0
@export var stamina_drain_per_second_behind: float = 5.0

@onready var target_label: Label = %TargetLabel
@onready var input_field: LineEdit = %InputField

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
	if _time_remaining <= 0.0:
		_finish(false)

func _on_text_changed(new_text: String) -> void:
	if _finished:
		return
	if new_text == target_text:
		_finish(true)
	elif not target_text.begins_with(new_text):
		_drain_behind_stamina(1.0)

func _drain_behind_stamina(delta_seconds: float) -> void:
	var main := Party.get_main_soldier()
	if main:
		main.apply_stat_delta("stamina", -stamina_drain_per_second_behind * delta_seconds)

func _finish(success: bool) -> void:
	_finished = true
	segment_completed.emit(success)

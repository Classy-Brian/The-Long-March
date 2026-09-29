extends Control
class_name DeathCutscene

## Plays the teammate's death art for a cause of death, then emits `finished`.
## Which images play is picked from keywords in `cause` (see _pick_sequence).
## During the stab images a twitching-hand layer loops on top at its own,
## faster speed (two flipbooks stacked, each flipping at its own rate).
## Click to skip.

signal finished

const DIR := "res://assets/Deathcutscene/"
const SEQUENCES := {
	"guard": ["DCMad1", "DCMad2", "stab1", "stab2", "stab3"],
	"dysentery": ["detentry1", "detentry2", "detentry3", "detentry4"],
	"heat": ["DCHeatstroke-hydration"],
	"wounds": ["DCbleed-wounds"],
	"truck": ["runover1", "runover2"],
}
## Overlay loop, shown while the main image name starts with "stab".
const TWITCH := ["twichhand1", "twichhand2", "twichhand3", "twichhand2"]

@export var frame_time: float = 1.0
@export var twitch_frame_time: float = 0.12
@export var hold_time: float = 2.0
@export var fade_in_time: float = 0.6

var cause: String = ""

@onready var picture: TextureRect = %Picture
@onready var overlay: TextureRect = %Overlay

var _steps: Array = []  # each step: [image name, seconds]
var _step: int = 0
var _time: float = 0.0
var _total: float = 0.0
var _twitch_index: int = 0
var _twitch_time: float = 0.0
var _done: bool = false

func _ready() -> void:
	for image in SEQUENCES[_pick_sequence(cause)]:
		_steps.append([image, frame_time])
	_steps.append([_steps[-1][0], hold_time])
	modulate.a = 0.0
	_show_step()

func _pick_sequence(text: String) -> String:
	var t := text.to_lower()
	if "dysentery" in t or "sick" in t:
		return "dysentery"
	if "dehydrat" in t or "heat" in t or "thirst" in t:
		return "heat"
	if "behind" in t or "beaten" in t or "guard" in t or "bayonet" in t or "shot" in t:
		return "guard"
	if "truck" in t or "run over" in t:
		return "truck"
	return "wounds"

func _process(delta: float) -> void:
	if _done:
		return
	_total += delta
	modulate.a = minf(1.0, _total / fade_in_time)
	_animate_overlay(delta)
	_time += delta
	if _time >= _steps[_step][1]:
		_time = 0.0
		_step += 1
		if _step >= _steps.size():
			_finish()
			return
		_show_step()

func _show_step() -> void:
	var image: String = _steps[_step][0]
	picture.texture = load(DIR + image + ".png")
	overlay.visible = image.begins_with("stab")

func _animate_overlay(delta: float) -> void:
	if not overlay.visible:
		return
	_twitch_time += delta
	if _twitch_time >= twitch_frame_time or overlay.texture == null:
		_twitch_time = 0.0
		overlay.texture = load(DIR + TWITCH[_twitch_index] + ".png")
		_twitch_index = (_twitch_index + 1) % TWITCH.size()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_finish()

func _finish() -> void:
	if _done:
		return
	_done = true
	finished.emit()

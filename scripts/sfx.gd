extends Node

## Sound manager - autoload singleton named "Sfx".
## Plays the ambient loop, marching footsteps, one-shot sounds, and a click

const SOUNDS := {
	"click": preload("res://assets/audio/uiclick.wav"),
	"type": preload("res://assets/audio/typeclick.wav"),  # first click of uiclick, trimmed short
	"step": preload("res://assets/audio/Footstep Grass 6.ogg"),
	"stab": preload("res://assets/audio/flesh-stab.wav"),
	"bones": preload("res://assets/audio/bones-cracking-482875.mp3"),
	"fall": preload("res://assets/audio/universfield-character-fall-impact-250069.mp3"),
}
const AMBIENT := preload("res://assets/audio/vgm-atmospheric-air.mp3")

const AMBIENT_VOLUME_DB := -10.0
## One entry per marcher in the column: seconds between their steps,
## volume (further back = quieter) and pitch (each boot sounds a bit different).
const MARCHERS := [
	{"interval": 0.92, "volume_db": -15.0, "pitch": 1.0},   # Sergeant
	{"interval": 0.86, "volume_db": -20.0, "pitch": 1.08},  # Private1
	{"interval": 0.92, "volume_db": -20.0, "pitch": 0.94},  # Private2
	{"interval": 0.99, "volume_db": -22.0, "pitch": 0.85},  # Guard (heavier boots)
]
const STEP_JITTER := 0.05  # random +/- seconds per step, so it sounds human
const CLICK_VOLUME_DB := -6.0

var _ambient: AudioStreamPlayer
var _step_timers: Array[Timer] = []
var _marching: bool = false

func _ready() -> void:
	_ambient = AudioStreamPlayer.new()
	_ambient.stream = AMBIENT
	_ambient.volume_db = AMBIENT_VOLUME_DB
	add_child(_ambient)
	_ambient.finished.connect(_ambient.play)
	_ambient.play()

	for i in MARCHERS.size():
		var timer := Timer.new()
		timer.one_shot = true
		timer.timeout.connect(_on_step.bind(i))
		add_child(timer)
		_step_timers.append(timer)

	get_tree().node_added.connect(_on_node_added)

## One-shot sound by name. Each call gets its own player,
## so sounds can overlap, and the player deletes itself when done.
func play(sound: String, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = SOUNDS[sound]
	player.volume_db = volume_db
	player.pitch_scale = pitch
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func set_footsteps(on: bool) -> void:
	if on == _marching:
		return
	_marching = on
	for i in _step_timers.size():
		if on:
			# Random first step, so the marchers aren't in perfect sync.
			_step_timers[i].start(randf_range(0.05, MARCHERS[i]["interval"]))
		else:
			_step_timers[i].stop()

func _on_step(i: int) -> void:
	var m: Dictionary = MARCHERS[i]
	play("step", m["volume_db"], m["pitch"] * randf_range(0.95, 1.05))
	_step_timers[i].start(m["interval"] + randf_range(-STEP_JITTER, STEP_JITTER))

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		node.pressed.connect(play.bind("click", CLICK_VOLUME_DB))

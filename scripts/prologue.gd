extends Control

## Prologue: historical context shown between the title screen and the march.
## Each page types itself out like a typewriter. Click / Enter / Space:
## first finishes the current page, then moves to the next.
## Edit the text in the Inspector (Pages) - no code needed.
##
## Dramatic typing:
## - Wrap words in *stars* to type them slowly, e.g. *Surrender.*
## - The typist pauses briefly after commas, longer after full stops and
##   line breaks, like someone choosing their words.

const MAIN_SCENE := "res://scenes/main/Main.tscn"

@export_multiline var pages: Array[String] = []
@export var chars_per_second: float = 26.0
@export var slow_chars_per_second: float = 6.0  ## for *starred* text
@export var comma_pause: float = 0.15
@export var period_pause: float = 0.45
@export var line_break_pause: float = 0.35
@export var type_sound_volume_db: float = -14.0
## Typewriter pitch range: lower = deeper, heavier keys.
@export var type_pitch_min: float = 0.6
@export var type_pitch_max: float = 0.75

@onready var text_label: Label = %TextLabel
@onready var hint_label: Label = %HintLabel

var _page: int = -1
var _delays: Array[float] = []  # seconds to wait after each character
var _visible: int = 0
var _wait: float = 0.0

func _ready() -> void:
	_next_page()

func _process(delta: float) -> void:
	if _page_done():
		hint_label.visible = true
		return
	_wait -= delta
	while _wait <= 0.0 and not _page_done():
		var c := text_label.text[_visible]
		_visible += 1
		text_label.visible_characters = _visible
		if c.strip_edges() != "":
			Sfx.play("type", type_sound_volume_db, randf_range(type_pitch_min, type_pitch_max))
		_wait += _delays[_visible - 1]

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_advance()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_advance()

func _advance() -> void:
	if _page_done():
		_next_page()
	else:
		_visible = text_label.text.length()  # skip the typing, show it all
		text_label.visible_characters = -1

func _next_page() -> void:
	_page += 1
	if _page >= pages.size():
		get_tree().change_scene_to_file(MAIN_SCENE)
		return
	_build_page(pages[_page])
	_visible = 0
	_wait = 0.6  # a breath before each page starts
	text_label.visible_characters = 0
	hint_label.visible = false

## Strips the *stars* out and works out how long to wait after each character.
func _build_page(raw: String) -> void:
	var shown := ""
	_delays.clear()
	var slow := false
	# Windows line endings sneak in "\r" characters, which Godot draws
	# as an extra line break. Strip them so blank lines stay single.
	raw = raw.replace("\r", "")
	for c in raw:
		if c == "*":
			slow = not slow
			continue
		shown += c
		var delay := 1.0 / (slow_chars_per_second if slow else chars_per_second)
		match c:
			",":
				delay += comma_pause
			".", "!", "?":
				delay += period_pause
			"\n":
				delay += line_break_pause
		_delays.append(delay)
	text_label.text = shown

func _page_done() -> bool:
	return _visible >= text_label.text.length()

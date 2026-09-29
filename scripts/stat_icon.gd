extends TextureRect
class_name StatIcon

@export var high: Texture2D
@export var mid: Texture2D
@export var low: Texture2D
@export var high_threshold: float = 66.0
@export var low_threshold: float = 33.0

func show_value(value: float) -> void:
	if value > high_threshold:
		texture = high
	elif value > low_threshold:
		texture = mid
	else:
		texture = low

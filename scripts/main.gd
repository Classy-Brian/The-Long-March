extends Node2D

@onready var ui_layer: CanvasLayer = %UILayer

func _ready() -> void:
	print("Main is ready. UI layer: ", ui_layer)

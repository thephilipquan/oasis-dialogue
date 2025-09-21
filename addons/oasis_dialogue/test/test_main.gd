extends Node

const CanvasFactory := preload("res://addons/oasis_dialogue/canvas/canvas_factory.gd")

func _ready() -> void:
	var canvas := CanvasFactory.create()
	add_child(canvas)

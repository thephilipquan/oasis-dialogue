@tool
extends EditorPlugin

const _CanvasFactory := preload("res://addons/oasis_dialogue/canvas/canvas_factory.gd")

var _canvas: Control = null


func _enter_tree() -> void:
	_canvas = _CanvasFactory.create()
	add_control_to_bottom_panel(_canvas, "Dialogue")


func _exit_tree() -> void:
	remove_control_from_bottom_panel(_canvas)
	_canvas.queue_free()

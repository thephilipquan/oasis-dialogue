@tool
extends EditorPlugin

const _CANVAS := preload("res://addons/oasis_dialogue/canvas/canvas.tscn")
var canvas: Control = null

func _enter_tree() -> void:
	canvas = _CANVAS.instantiate()
	add_control_to_bottom_panel(canvas, "dialogue")


func _exit_tree() -> void:
	remove_control_from_bottom_panel(canvas)
	canvas.queue_free()

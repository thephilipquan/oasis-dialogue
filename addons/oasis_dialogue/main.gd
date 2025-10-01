@tool
extends EditorPlugin

const _App := preload("res://addons/oasis_dialogue/oasis_dialogue/oasis_dialogue.gd")

var _app: _App = null


func _enter_tree() -> void:
	_app = _App.new()
	add_control_to_bottom_panel(_app, "Dialogue")


func _exit_tree() -> void:
	remove_control_from_bottom_panel(_app)
	_app.queue_free()

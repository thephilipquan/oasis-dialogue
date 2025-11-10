@tool
extends EditorPlugin

const _App := preload("res://addons/oasis_dialogue/main/main.gd")
const _AppScene := preload("res://addons/oasis_dialogue/main/main.tscn")

var _app: _App = null


func _enter_tree() -> void:
	_app = _AppScene.instantiate()
	add_control_to_bottom_panel(_app, "Dialogue")


func _exit_tree() -> void:
	remove_control_from_bottom_panel(_app)
	_app.queue_free()

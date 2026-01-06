@tool
extends EditorPlugin

const _App := preload("res://addons/oasis_dialogue/main/main.gd")
const _AppScene := preload("res://addons/oasis_dialogue/main/main.tscn")

var _app: _App = null


func _enter_tree() -> void:
	_app = _AppScene.instantiate()
	EditorInterface.get_editor_main_screen().add_child(_app)
	_app.hide()


func _exit_tree() -> void:
	_app.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	_app.visible = visible


func _get_plugin_name():
	return "OasisDialogue"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")

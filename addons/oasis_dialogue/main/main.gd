@tool
extends Control

const _ProjectDialog := preload("res://addons/oasis_dialogue/project_dialog/project_dialog.gd")
const _ProjectDialogScene := preload("res://addons/oasis_dialogue/project_dialog/project_dialog.tscn")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Project := preload("res://addons/oasis_dialogue/canvas/canvas.gd")
const _ProjectScene := preload("res://addons/oasis_dialogue/canvas/canvas.tscn")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")


var _manager: _ProjectManager = null

var _project_dialog: _ProjectDialog = null
var _project: _Project = null

func _ready() -> void:
	_open_project_dialog()


func _open_project_dialog() -> void:
	_project_dialog = _ProjectDialogScene.instantiate()
	add_child(_project_dialog)
	_project_dialog.path_requested.connect(_on_project_path_requested)


func _on_project_path_requested(path: String) -> void:
	_project_dialog.queue_free()
	remove_child(_project_dialog)

	_manager = _ProjectManager.new()
	_manager.add_to_group("registerable")
	add_child(_manager)

	_project = _ProjectScene.instantiate()
	add_child(_project)

	var registry := _Registry.new()
	add_child(registry)
	registry.queue_free()
	remove_child(registry)

	_manager.open_project(path)

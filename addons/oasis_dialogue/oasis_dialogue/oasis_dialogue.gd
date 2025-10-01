@tool
extends Control

const _ProjectDialog := preload("res://addons/oasis_dialogue/project_dialog/project_dialog.gd")
const _ProjectDialogScene := preload("res://addons/oasis_dialogue/project_dialog/project_dialog.tscn")
const _ProjectManager := preload("res://addons/oasis_dialogue/project_manager.gd")
const _Project := preload("res://addons/oasis_dialogue/canvas/canvas.gd")
const _ProjectScene := preload("res://addons/oasis_dialogue/canvas/canvas.tscn")


var _manager: _ProjectManager = null

var _project_dialog: _ProjectDialog = null
var _project: _Project = null

func _ready() -> void:
	_manager = _ProjectManager.new()
	_open_project_dialog()


func _open_project_dialog() -> void:
	_project_dialog = _ProjectDialogScene.instantiate()
	add_child(_project_dialog)
	_project_dialog.create_project_requested.connect(_on_project_dialog_selection.bind(_manager.new_project))
	_project_dialog.load_project_requested.connect(_on_project_dialog_selection.bind(_manager.load_project))


func _on_project_dialog_selection(path: String, callback: Callable) -> void:
	_project_dialog.queue_free()
	remove_child(_project_dialog)

	_project = _ProjectScene.instantiate()
	add_child(_project)
	_project.init(_manager)

	callback.call(path)

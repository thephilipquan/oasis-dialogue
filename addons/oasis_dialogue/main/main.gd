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

@onready
var _registry: _Registry = $Registry


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	_create_project_dialog()
	_registry.trigger()


func _exit_tree() -> void:
	if is_part_of_edited_scene():
		return

	# Closed with project open.
	if _manager:
		_manager.quit()


func quit() -> void:
	get_tree().quit(0)


func open_project(path: String) -> void:
	_remove_project_dialog()
	_create_project_manager()
	_create_project()
	_registry.trigger()
	_manager.open_project(path)


func close_project() -> void:
	_remove_project_manager()
	_remove_project()
	_create_project_dialog()
	_registry.trigger()


func _create_project_dialog() -> void:
	_project_dialog = _ProjectDialogScene.instantiate()
	_project_dialog.add_to_group(_Registry.GROUP)
	add_child(_project_dialog)
	_project_dialog.path_requested.connect(open_project)


func _remove_project_dialog() -> void:
	remove_child(_project_dialog)
	_project_dialog.queue_free()


func _create_project_manager() -> void:
	_manager = _ProjectManager.new()
	_manager.add_to_group(_Registry.GROUP)
	add_child(_manager)


func _remove_project_manager() -> void:
	_manager.quit()
	remove_child(_manager)
	_manager = null


func _create_project() -> void:
	_project = _ProjectScene.instantiate()
	_project.close_requested.connect(close_project)
	_project.quit_requested.connect(quit)
	add_child(_project)


func _remove_project() -> void:
	remove_child(_project)
	_project.queue_free()
	_project = null

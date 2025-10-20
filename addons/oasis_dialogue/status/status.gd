@tool
extends Control

const REGISTRY_KEY := "status"

const _AddBranchButton := preload("res://addons/oasis_dialogue/canvas/add_branch_button.gd")
const _AddCharacterButton := preload("res://addons/oasis_dialogue/canvas/add_character_button.gd")
const _BranchEdit := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _Canvas := preload("res://addons/oasis_dialogue/canvas/canvas.gd")
const _CharacterTree := preload("res://addons/oasis_dialogue/canvas/character_tree.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _RemoveCharacterButton := preload("res://addons/oasis_dialogue/canvas/remove_character_button.gd")
const _RenameCharacterHandler := preload("res://addons/oasis_dialogue/canvas/rename_character_handler.gd")
const _StatusLabel := preload("res://addons/oasis_dialogue/status/status_label.gd")

@export
var _invalid_color := Color()
@export_range(0.1, 3.0, 0.1)
var _duration := 2.0

var _get_active_character := Callable()
var _status_label_factory := Callable()

var _errors: Dictionary[int, _StatusLabel] = {}

@onready
var _container: VBoxContainer = $MarginContainer/VBoxContainer


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	_status_label_factory = registry.at(_Canvas.STATUS_LABEL_FACTORY_REGISTRY_KEY)

	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	_get_active_character = manager.get_active_character

	var _rename_character_handler: _RenameCharacterHandler = registry.at(_RenameCharacterHandler.REGISTRY_KEY)
	_rename_character_handler.character_renamed.connect(rename_character)

	var add_branch_button: _AddBranchButton = registry.at(_AddBranchButton.REGISTRY_KEY)
	add_branch_button.branch_added.connect(add_branch)

	var add_character_button: _AddCharacterButton = registry.at(_AddCharacterButton.REGISTRY_KEY)
	add_character_button.character_added.connect(add_character)

	var remove_character_button: _RemoveCharacterButton = registry.at(_RemoveCharacterButton.REGISTRY_KEY)
	remove_character_button.character_removed.connect(remove_character)

	var tree: _CharacterTree = registry.at(_CharacterTree.REGISTRY_KEY)
	tree.character_selected.connect(clear_errs.unbind(1))

	var graph: _BranchEdit = registry.at(_BranchEdit.REGISTRY_KEY)
	graph.branch_removed.connect(remove_branch)

	manager.saving_character.connect(save_file.unbind(1))
	manager.saving_settings.connect(save_project.unbind(1))


func init_get_active_character(callback: Callable) -> void:
	_get_active_character = callback


func init_status_label_factory(status_label_factory: Callable) -> void:
	_status_label_factory = status_label_factory


func add_branch(id: int) -> void:
	info("Added branch %d" % id)


func remove_branch(id: int) -> void:
	info("Removed branch %d" % id)


func rename_character(to: String) -> void:
	info("Renamed %s to %s" % [_get_active_character.call() , to] )


func remove_character() -> void:
	info("Removed %s" % _get_active_character.call())


func add_character(name: String) -> void:
	info("Added %s" % name)


func save_file() -> void:
	info("Saved %s" % _get_active_character.call())


func save_project() -> void:
	info("Saved project")


func clear_labels() -> void:
	for child in _container.get_children():
		child.queue_free()
		_container.remove_child(child)


func info(message: String) -> void:
	var label: _StatusLabel = _status_label_factory.call()
	_container.add_child(label)
	label.init(message, _duration)


func err(id: int, message: String) -> void:
	var label: _StatusLabel = _status_label_factory.call()
	_container.add_child(label)
	label.init(message, 0)
	label.set_color(_invalid_color)
	if id in _errors:
		var old_label := _errors[id]
		_container.remove_child(old_label)
		old_label.queue_free()
	_errors[id] = label


func clear_err(id: int) -> void:
	if not id in _errors:
		return
	var label := _errors[id]
	label.fade()
	_errors.erase(id)


func clear_errs() -> void:
	for error in _errors.values():
		_container.remove_child(error)
		error.queue_free()
	_errors.clear()

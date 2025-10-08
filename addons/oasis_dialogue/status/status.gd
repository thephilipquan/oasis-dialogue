@tool
extends Control

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

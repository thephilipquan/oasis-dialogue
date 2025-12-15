
extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _Error := preload("res://addons/oasis_dialogue/model/semantic_error.gd")

var _on_err := Callable()
var _is_enabled := Callable()
var _is_exclusive := Callable()

var _id := -1
var _seen: Dictionary[String, bool] = {}


func init_on_err(callback: Callable) -> void:
	_on_err = callback


func init_is_enabled(callback: Callable) -> void:
	_is_enabled = callback


func init_is_exclusive(callback: Callable) -> void:
	_is_exclusive = callback


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_annotation(annotation: _AST.Annotation) -> void:
	if not _is_enabled.call() or not _is_exclusive.call(annotation.name):
		return

	if _seen.size():
		var error := _Error.new()
		error.id = _id
		error.message = "%s conflicts with %s" % [annotation.name, _seen.keys()]
		error.line = annotation.line
		error.column = annotation.column
		_on_err.call(error)

	_seen[annotation.name] = true


func cancel() -> void:
	_seen.clear()
	_id = -1


func finish() -> void:
	cancel()

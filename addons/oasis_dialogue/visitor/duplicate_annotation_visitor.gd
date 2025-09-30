extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _SemanticError := preload("res://addons/oasis_dialogue/semantic_error.gd")

signal erred(error: _SemanticError)

var _id := -1
var _seen: Dictionary[String, bool] = {}
var _stop := Callable()


func _init(stop_iterator: Callable) -> void:
	_stop = stop_iterator


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id
	_seen  = {}


func visit_annotation(annotation: _AST.Annotation) -> void:
	if annotation.name in _seen:
		var error := _SemanticError.new()
		error.id = _id
		error.message = "There should only be 1 @%s." % annotation.name
		error.line = annotation.line
		error.column = annotation.column
		erred.emit(error)
		_stop.call()
		return
	_seen[annotation.name] = true


func cancel() -> void:
	finish()


func finish() -> void:
	_seen.clear()

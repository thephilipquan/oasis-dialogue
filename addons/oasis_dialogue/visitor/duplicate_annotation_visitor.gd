extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _SemanticError := preload("res://addons/oasis_dialogue/model/semantic_error.gd")

var _id := -1
var _seen: Dictionary[String, bool] = {}
var _on_err := Callable()


func _init(on_err: Callable) -> void:
	_on_err = on_err


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
		_on_err.call(error)
	else:
		_seen[annotation.name] = true


func cancel() -> void:
	finish()


func finish() -> void:
	_seen.clear()

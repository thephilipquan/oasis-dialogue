extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _SemanticError := preload("res://addons/oasis_dialogue/model/semantic_error.gd")

var _on_err := Callable()

var _id := -1
var _seen_error := false


func _init(on_err: Callable) -> void:
	_on_err = on_err


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_error(error: _AST.Error) -> void:
	if _seen_error:
		return
	_seen_error = true
	var semantic_error := _SemanticError.new()
	semantic_error.id = _id
	semantic_error.message = error.message
	semantic_error.line = error.line
	semantic_error.column = error.column
	_on_err.call(semantic_error)


func cancel() -> void:
	_id = -1
	_seen_error = false


func finish() -> void:
	cancel()

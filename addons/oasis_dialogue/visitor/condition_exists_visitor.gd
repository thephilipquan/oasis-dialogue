extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _SemanticError := preload("res://addons/oasis_dialogue/semantic_error.gd")

var _id := -1
var _condition_exists := Callable()
var _on_err := Callable()


func _init(condition_exists: Callable, on_err: Callable) -> void:
	_condition_exists = condition_exists
	_on_err = on_err


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_condition(condition: _AST.Condition) -> void:
	if _condition_exists.call(condition.name):
		return

	var error := _SemanticError.new()
	error.id = _id
	error.message = "Condition %s not recognized." % condition.name
	error.line = condition.line
	error.column = condition.column
	_on_err.call(error)


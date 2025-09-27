extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _SemanticError := preload("res://addons/oasis_dialogue/semantic_error.gd")

signal erred(error: _SemanticError)

var _id := -1
var _condition_exists := Callable()


func _init(condition_exists: Callable) -> void:
	_condition_exists = condition_exists


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_condition(condition: _AST.Condition) -> void:
	if _condition_exists.call(condition.name):
		return

	var error := _SemanticError.new()
	error.id = _id
	error.message = "Condition %s not recognized." % condition.name
	erred.emit(error)

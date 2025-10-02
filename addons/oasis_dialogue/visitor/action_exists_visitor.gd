extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _SemanticError := preload("res://addons/oasis_dialogue/semantic_error.gd")

var _id := -1
var _action_exists := Callable()
var _on_err := Callable()


func _init(action_exists: Callable, on_err: Callable) -> void:
	_action_exists = action_exists
	_on_err = on_err


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_action(action: _AST.Action) -> void:
	if _action_exists.call(action.name):
		return

	var error := _SemanticError.new()
	error.id = _id
	error.message = "Action %s not recognized." % action.name
	error.line = action.line
	error.column = action.column
	_on_err.call(error)

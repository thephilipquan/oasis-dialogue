extends "res://addons/oasis_dialogue/model/visitor.gd"

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
	_on_err.call(_id, "Action %s not recognized." % action.name)

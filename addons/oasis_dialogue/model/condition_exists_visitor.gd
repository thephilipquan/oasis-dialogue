extends "res://addons/oasis_dialogue/model/visitor.gd"

var _id := -1
var _condition_exists := Callable()
var _on_err := Callable()


func _init(condition_exists: Callable, on_err: Callable) -> void:
	_condition_exists = condition_exists
	_on_err = on_err


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_condition(condition: _AST.Condition) -> void:
	# maybe default condition has_seen and not_seen_branch
	if _condition_exists.call(condition.name):
		return
	_on_err.call(_id, "Condition %s not recognized." % condition.name)


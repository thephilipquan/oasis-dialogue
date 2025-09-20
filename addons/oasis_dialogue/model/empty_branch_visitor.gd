extends "res://addons/oasis_dialogue/model/visitor.gd"

var _id := -1
var _stop_iterator := Callable()
var _on_err := Callable()

func _init(stop_iterator: Callable, on_err: Callable) -> void:
	_stop_iterator = stop_iterator
	_on_err = on_err


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id
	if branch.prompts or branch.responses:
		return
	_stop_iterator.call()
	_on_err.call(_id, "Empty branch.")


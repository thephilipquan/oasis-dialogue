extends "res://addons/oasis_dialogue/model/visitor.gd"

var _id := -1
var _stop_iterator := Callable()
var _on_err := Callable()
var _seen: Dictionary[String, bool] = {}

func _init(stop_iterator: Callable, on_err: Callable) -> void:
	_stop_iterator = stop_iterator
	_on_err = on_err


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id
	_seen  = {}


func visit_annotation(annotation: _AST.Annotation) -> void:
	if annotation.name in _seen:
		_on_err.call(_id, "There should only be 1 @%s." % annotation.name)
		_stop_iterator.call()
		return
	_seen[annotation.name] = true


func cancel() -> void:
	finish()


func finish() -> void:
	_seen.clear()

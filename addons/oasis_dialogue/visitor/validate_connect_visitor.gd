extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _SemanticError := preload("res://addons/oasis_dialogue/semantic_error.gd")

signal erred(error: _SemanticError)

var _connect_keyword := ""
var _stop := Callable()

var _id := -1

func _init(connect_keyword: String, stop_iterator: Callable) -> void:
	_connect_keyword = connect_keyword
	_stop = stop_iterator


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_action(action: _AST.Action) -> void:
	if action.name != _connect_keyword:
		return
	elif not action.value:
		emit_error("Missing branch id after %s action." % _connect_keyword)
		_stop.call()
	elif action.value.value == _id:
		emit_error("Cannot %s to itself." % _connect_keyword)
		_stop.call()


func cancel() -> void:
	_id = -1


func finish() -> void:
	cancel()


func emit_error(message: String) -> void:
	var error := _SemanticError.new()
	error.id = _id
	error.message = message
	erred.emit(error)

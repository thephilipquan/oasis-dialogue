extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _SemanticError := preload("res://addons/oasis_dialogue/semantic_error.gd")

signal erred(error: _SemanticError)

var _connect_keyword := ""
var _connect_branches := Callable()
var _stop := Callable()

var _id := -1
var _to_branches: Array[int] = []


func _init(connect_keyword: String, connect_branches: Callable, stop_iterator: Callable) -> void:
	_connect_keyword = connect_keyword
	_connect_branches = connect_branches
	_stop = stop_iterator


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_action(action: _AST.Action) -> void:
	if action.name != _connect_keyword:
		return

	var number := action.value as _AST.NumberLiteral
	if not number:
		emit_error("Missing branch id after %s action." % _connect_keyword)
		_stop.call()
		return

	var to := number.value
	if _id == to:
		emit_error("Cannot %s to itself." % _connect_keyword)
		_stop.call()
		return

	_to_branches.push_back(to)


func cancel() -> void:
	_id = -1
	_to_branches.clear()


func finish() -> void:
	_connect_branches.call(_id, _to_branches.duplicate())
	cancel()


func emit_error(message: String) -> void:
	var error := _SemanticError.new()
	error.id = _id
	error.message = message
	erred.emit(error)

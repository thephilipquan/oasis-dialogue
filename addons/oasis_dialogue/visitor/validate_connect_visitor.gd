extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _SemanticError := preload("res://addons/oasis_dialogue/model/semantic_error.gd")

var _connect_keyword := ""
var _on_err := Callable()

var _id := -1

func _init(connect_keyword: String, on_err: Callable) -> void:
	_connect_keyword = connect_keyword
	_on_err = on_err


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_action(action: _AST.Action) -> void:
	if action.name != _connect_keyword:
		return
	elif not action.value:
		emit_error("Missing branch id after %s action." % _connect_keyword, action.line, action.column)


func cancel() -> void:
	_id = -1


func finish() -> void:
	cancel()


func emit_error(message: String, line: int, column: int) -> void:
	var error := _SemanticError.new()
	error.id = _id
	error.line = line
	error.column = column
	error.message = message
	_on_err.call(error)

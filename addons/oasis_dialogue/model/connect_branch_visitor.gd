extends "res://addons/oasis_dialogue/model/visitor.gd"

var _id := -1
var _connect_keyword := ""
var _to_branches: Array[int] = []
var _connect_branches := Callable()
var _on_err := Callable()


func _init(connect_keyword: String, connect_branches: Callable, on_err: Callable) -> void:
	_connect_keyword = connect_keyword
	_connect_branches = connect_branches
	_on_err = on_err


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_action(action: _AST.Action) -> void:
	if action.name != _connect_keyword:
		return

	var number := action.value as _AST.NumberLiteral
	if not number:
		_on_err.call(_id, "Missing branch id after %s action." % _connect_keyword)
		return

	var to := number.value
	if _id == to:
		_on_err.call(_id, "Cannot %s to itself." % _connect_keyword)
		return

	_to_branches.push_back(to)


func cancel() -> void:
	_id = -1
	_to_branches.clear()


func finish() -> void:
	_connect_branches.call(_id, _to_branches.duplicate())
	cancel()

extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _SemanticError := preload("res://addons/oasis_dialogue/semantic_error.gd")

var _connect_keyword := ""
var _connect_branches := Callable()

var _id := -1
var _to_branches: Array[int] = []


func _init(connect_keyword: String, connect_branches: Callable) -> void:
	_connect_keyword = connect_keyword
	_connect_branches = connect_branches


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_action(action: _AST.Action) -> void:
	if action.name != _connect_keyword:
		return
	_to_branches.push_back(action.value.value)


func cancel() -> void:
	_id = -1
	_to_branches.clear()


func finish() -> void:
	_connect_branches.call(_id, _to_branches.duplicate())
	cancel()

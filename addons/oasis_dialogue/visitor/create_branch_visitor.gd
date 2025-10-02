extends "res://addons/oasis_dialogue/visitor/visitor.gd"

var _create_branch_keyword := ""
var _branch_exists := Callable()
var _add_branch := Callable()

var _to_create: Array[int] = []


func _init(create_branch_keyword: String, branch_exists: Callable, add_branch: Callable) -> void:
	_create_branch_keyword = create_branch_keyword
	_branch_exists = branch_exists
	_add_branch = add_branch


func visit_action(action: _AST.Action) -> void:
	if action.name != _create_branch_keyword:
		return

	if not action.value:
		return

	var id := action.value.value
	if not _branch_exists.call(id):
		_to_create.push_back(id)


func cancel() -> void:
	_to_create.clear()


func finish() -> void:
	for id in _to_create:
		_add_branch.call(id)
	cancel()

extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _Model := preload("res://addons/oasis_dialogue/model/model.gd")
const _Graph := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")

var _create_branch_keyword := ""
var _model: _Model = null
var _graph: _Graph = null

var _to_create: Array[int] = []


func _init(create_branch_keyword: String, model: _Model, graph: _Graph) -> void:
	_create_branch_keyword = create_branch_keyword
	_model = model
	_graph = graph


func visit_action(action: _AST.Action) -> void:
	if not action.name == _create_branch_keyword:
		return

	var id := action.value.value
	if not _model.has_branch(id):
		_to_create.push_back(id)


func cancel() -> void:
	_to_create.clear()


func finish() -> void:
	for id in _to_create:
		_model.add_branch(id)
		_graph.add_branch(id)
	cancel()


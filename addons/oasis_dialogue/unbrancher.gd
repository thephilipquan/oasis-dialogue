## Cleans AST values in response to [signal BranchEdit.branches_dirtied].
extends Node

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Model := preload("res://addons/oasis_dialogue/model/model.gd")
const _VisitorIterator := preload("res://addons/oasis_dialogue/visitor/visitor_iterator.gd")

## Emitted when an [AST] is updated and needs the change reflected on [Branch].
signal unparse_requested(ast: _AST.Branch)

@export
var _model: _Model = null
var _visitors_factory := Callable()


func init(visitors_factory: Callable) -> void:
	_visitors_factory = visitors_factory


func clean_branches(removed_id: int, dirty_ids: Array[int]) -> void:
	var visitors: _VisitorIterator = _visitors_factory.call(removed_id)

	for id in dirty_ids:
		var ast := _model.get_branch(id)
		visitors.iterate(ast)
		_model.update_branch(ast)
		unparse_requested.emit(ast)

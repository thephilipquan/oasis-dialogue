@tool
extends Node

const REGISTRY_KEY := "unbrancher_visitors"

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _BranchEdit := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _Global := preload("res://addons/oasis_dialogue/global.gd")
const _Model := preload("res://addons/oasis_dialogue/model/model.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _RemoveActionVisitor := preload("res://addons/oasis_dialogue/visitor/remove_action_visitor.gd")
const _UnparserVisitor := preload("res://addons/oasis_dialogue/visitor/unparser_visitor.gd")
const _VisitorIterator := preload("res://addons/oasis_dialogue/visitor/visitor_iterator.gd")
const _LanguageServer := preload("res://addons/oasis_dialogue/canvas/language_server.gd")


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var graph: _BranchEdit = registry.at(_BranchEdit.REGISTRY_KEY)
	var unparser_visitor := _UnparserVisitor.new(graph.update_branch)
	var language_server: _LanguageServer = registry.at(_LanguageServer.REGISTRY_KEY)

	# Visitors to handle removal of text in affected branches after a branch
	# is removed needs to be created on demand.
	# Refactor this to BranchRemovalCleaner
	var unbranch_removed := func unbranch_from_deleted(removed_id: int, dirty_ids: Array[int]) -> void:
		var visitors := _VisitorIterator.new()
		visitors.set_visitors([
			_RemoveActionVisitor.new(
				_AST.Action.new(
					_Global.CONNECT_BRANCH_KEYWORD,
					_AST.NumberLiteral.new(removed_id)
				)
			),
			unparser_visitor,
		])

		for id in dirty_ids:
			var ast := language_server.parse_branch_text(id, graph.get_branch_text(id))
			visitors.iterate(ast)
	graph.branches_dirtied.connect(unbranch_removed)

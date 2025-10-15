@tool
extends Node

const REGISTRY_KEY := "branch_reconstructor"

const _UnparserVisitor := preload("res://addons/oasis_dialogue/visitor/unparser_visitor.gd")
const _VisitorIterator := preload("res://addons/oasis_dialogue/visitor/visitor_iterator.gd")

const _Model := preload("res://addons/oasis_dialogue/model/model.gd")
const _BranchEdit := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

var _visitors: _VisitorIterator = null


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var model: _Model = registry.at(_Model.REGISTRY_KEY)
	var graph: _BranchEdit = registry.at(_BranchEdit.REGISTRY_KEY)

	var _visitors := _VisitorIterator.new()
	var unparser_visitor := _UnparserVisitor.new(graph.update_branch)
	_visitors.set_visitors([
		unparser_visitor,
	])

	var restore_branch := func restore_branches(id: int) -> void:
		var ast := model.get_branch(id)
		_visitors.iterate(ast)
	graph.branch_restored.connect(restore_branch)

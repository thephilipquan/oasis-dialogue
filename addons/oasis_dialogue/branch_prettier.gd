@tool
extends Node

const REGISTRY_KEY := "branch_prettier"

const _Graph := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _LanguageServer := preload("res://addons/oasis_dialogue/canvas/language_server.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _UnparserVisitor := preload("res://addons/oasis_dialogue/visitor/unparser_visitor.gd")
const _VisitorIterator := preload("res://addons/oasis_dialogue/visitor/visitor_iterator.gd")

var _visitors: _VisitorIterator = null


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	_visitors = _VisitorIterator.new()

	var graph: _Graph = registry.at(_Graph.REGISTRY_KEY)
	var silent_update := true
	var unparser_visitor := _UnparserVisitor.new(graph.update_branch.bind(silent_update))

	_visitors.set_visitors([
			unparser_visitor,
	])

	var language_server: _LanguageServer = registry.at(_LanguageServer.REGISTRY_KEY)
	var pretty_branch := func pretty_branch(id: int) -> void:
		var ast := language_server.parse_branch_text(id, graph.get_branch_text(id))
		_visitors.iterate(ast)

	graph.pretty_requested.connect(pretty_branch)

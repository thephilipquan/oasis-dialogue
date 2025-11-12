@tool
extends Node

const REGISTRY_KEY := "semantic_visitors"

const _BranchEdit := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _Global := preload("res://addons/oasis_dialogue/global.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _SemanticError := preload("res://addons/oasis_dialogue/model/semantic_error.gd")
const _Status := preload("res://addons/oasis_dialogue/status/status.gd")
const _Token := preload("res://addons/oasis_dialogue/model/token.gd")
const _VisitorIterator := preload("res://addons/oasis_dialogue/visitor/visitor_iterator.gd")

const _ConnectBranchVisitor := preload("res://addons/oasis_dialogue/visitor/connect_branch_visitor.gd")
const _CreateBranchVisitor := preload("res://addons/oasis_dialogue/visitor/create_branch_visitor.gd")
const _DuplicateAnnotationVisitor := preload("res://addons/oasis_dialogue/visitor/duplicate_annotation_visitor.gd")
const _EmptyBranchVisitor := preload("res://addons/oasis_dialogue/visitor/empty_branch_visitor.gd")
const _FinishCallbackVisitor := preload("res://addons/oasis_dialogue/visitor/finish_callback_visitor.gd")
const _LanguageServer := preload("res://addons/oasis_dialogue/canvas/language_server.gd")
const _ParseErrorVisitor := preload("res://addons/oasis_dialogue/visitor/parse_error_visitor.gd")
const _UniqueTypeVisitor := preload("res://addons/oasis_dialogue/visitor/unique_type_visitor.gd")
const _ValidateConnectVisitor := preload("res://addons/oasis_dialogue/visitor/validate_connect_visitor.gd")

var _visitors: _VisitorIterator = null


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var graph: _BranchEdit = registry.at(_BranchEdit.REGISTRY_KEY)
	var status: _Status = registry.at(_Status.REGISTRY_KEY)

	_visitors = _VisitorIterator.new()

	var on_err := func(e: _SemanticError) -> void:
		status.err(e.id, e.message)
		graph.highlight_branch(e.id, [e.line])
		_visitors.stop()

	var parse_error_visitor := _ParseErrorVisitor.new(on_err)
	var empty_branch_visitor := _EmptyBranchVisitor.new(on_err)
	var duplicate_annotation_visitor := _DuplicateAnnotationVisitor.new(on_err)
	var unique_type_visitor := _UniqueTypeVisitor.new(
		_Token.type_to_string(_Token.Type.RNG),
		_Token.type_to_string(_Token.Type.SEQ),
	)
	unique_type_visitor.init_on_err(on_err)
	var validate_connect_visitor := _ValidateConnectVisitor.new(
		_Global.CONNECT_BRANCH_KEYWORD,
		on_err,
	)
	var create_branch_visitor := _CreateBranchVisitor.new(
		_Global.CONNECT_BRANCH_KEYWORD,
		graph.has_branch,
		func(id: int) -> void:
			graph.add_branch(id)
			status.add_branch(id),
	)
	var connect_branch_visitor := _ConnectBranchVisitor.new(
		_Global.CONNECT_BRANCH_KEYWORD,
		graph.connect_branches,
		graph.is_interactive_connect,
	)
	var clear_status_err := _FinishCallbackVisitor.new(status.clear_err)
	var clear_branch_highlights_visitor := _FinishCallbackVisitor.new(graph.clear_branch_highlights)
	_visitors.set_visitors([
		parse_error_visitor,
		empty_branch_visitor,
		duplicate_annotation_visitor,
		unique_type_visitor,
		validate_connect_visitor,
		create_branch_visitor,
		connect_branch_visitor,
		clear_branch_highlights_visitor,
		clear_status_err,
	])

	var language_server: _LanguageServer = registry.at(_LanguageServer.REGISTRY_KEY)
	var semantic_visit := func semantic_visit(id: int, text: String) -> void:
			var ast := language_server.parse_branch_text(id, text)
			_visitors.iterate(ast)

	graph.branch_changed.connect(semantic_visit)

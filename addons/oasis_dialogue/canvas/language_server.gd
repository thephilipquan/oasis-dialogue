@tool
extends Node

const REGISTRY_KEY := "language_server"

const _Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const _BranchEdit := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")
const _Parser := preload("res://addons/oasis_dialogue/model/parser.gd")

signal parsed(ast: _AST.Branch)

var _lexer: _Lexer = null
var _parser: _Parser = null


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	_lexer = registry.at(_Lexer.REGISTRY_KEY)
	_parser = registry.at(_Parser.REGISTRY_KEY)

	var graph: _BranchEdit = registry.at(_BranchEdit.REGISTRY_KEY)
	graph.branch_added.connect(
		func connect_branch_to_language_server(branch: _Branch) -> void:
			branch.changed.connect(parse_branch_text)
	)


func parse_branch_text(id: int, text: String) -> void:
	var tokens := _lexer.tokenize(text)
	var ast := _parser.parse(tokens)
	ast.id = id
	parsed.emit(ast)

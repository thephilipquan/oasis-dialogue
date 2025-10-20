@tool
extends Node

const REGISTRY_KEY := "language_server"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")
const _Parser := preload("res://addons/oasis_dialogue/model/parser.gd")

var _lexer: _Lexer = null
var _parser: _Parser = null


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	init_lexer(registry.at(_Lexer.REGISTRY_KEY))
	init_parser(registry.at(_Parser.REGISTRY_KEY))


func init_lexer(lexer: _Lexer) -> void:
	_lexer = lexer


func init_parser(parser: _Parser) -> void:
	_parser = parser


func parse_branch_text(id: int, text: String) -> _AST.AST:
	var tokens := _lexer.tokenize(text)
	var ast := _parser.parse(tokens)
	ast.id = id
	return ast

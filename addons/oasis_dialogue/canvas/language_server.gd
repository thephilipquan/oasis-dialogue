extends RefCounted

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")
const _Parser := preload("res://addons/oasis_dialogue/model/parser.gd")

signal parsed(ast: _AST.Branch)

var _lexer: _Lexer = null
var _parser: _Parser = null


func _init(lexer: _Lexer, parser: _Parser) -> void:
	_lexer = lexer
	_parser = parser


func parse_branch_text(id: int, text: String) -> void:
	var tokens := _lexer.tokenize(text)
	var ast := _parser.parse(tokens)
	ast.id = id
	parsed.emit(ast)


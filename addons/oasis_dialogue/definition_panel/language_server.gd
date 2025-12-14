@tool
extends Node

const _AST := preload("res://addons/oasis_dialogue/definition_panel/model/ast.gd")
const _Lexer := preload("res://addons/oasis_dialogue/definition_panel/model/lexer.gd")
const _Parser := preload("res://addons/oasis_dialogue/definition_panel/model/parser.gd")
const _Shared := preload("res://addons/oasis_dialogue/definition_panel/shared.gd")

signal parsed(ast: _AST)

@export
var _shared: _Shared = null

var _lexer: _Lexer = null
var _parser := _Parser.new()


func _ready() -> void:
	_lexer = _shared.lexer


func parse(text: String) -> void:
	var tokens := _lexer.tokenize(text)
	var ast := _parser.parse(tokens)
	parsed.emit(ast)

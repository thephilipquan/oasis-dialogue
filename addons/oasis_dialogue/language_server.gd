extends Node

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const _Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")
const _Parser := preload("res://addons/oasis_dialogue/model/parser.gd")
const _ParseError := preload("res://addons/oasis_dialogue/model/parse_error.gd")
const _BranchEdit := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")

signal parsed(ast: _AST.Branch)
signal erred(id: int, errors: _ParseError)

var _lexer: _Lexer = null
var _parser: _Parser = null


func init(lexer: _Lexer, parser: _Parser) -> void:
	_lexer = lexer
	_parser = parser


func parse_branch_text(id: int, text: String) -> void:
	var tokens := _lexer.tokenize(text)
	var ast := _parser.parse(tokens)
	ast.id = id
	var errors := _parser.get_errors()
	if errors:
		erred.emit(id, errors)
	else:
		parsed.emit(ast)

	# var error_lines: Array[int] = []
	# error_lines.assign(errors.map(func(e: _Parser.ParseError): return e.line))

	# var branch := _branch_edit.get_branch(id)
	# branch.highlight(error_lines)
	# branch.color_normal()

	# if errors:
		# push_warning("todo status")
		# return

	# ast.id = id
	# _visitors.iterate(ast)

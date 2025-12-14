extends "res://addons/oasis_dialogue/definition_panel/visitor/visitor.gd"

const _Error := preload("res://addons/oasis_dialogue/definition_panel/model/error.gd")

var _on_err := Callable()


func init_on_err(callback: Callable) -> void:
	_on_err = callback


func visit_error(ast: _AST.Error) -> void:
	var error := _Error.new(ast.message, ast.line, ast.column)
	_on_err.call(error)

extends "res://addons/oasis_dialogue/definitions/visitor/visitor.gd"

const _Error := preload("res://addons/oasis_dialogue/definitions/model/error.gd")

var _seen: Dictionary[String, bool] = {} # Dummy value.
var _on_err := Callable()


func init_on_err(callback: Callable) -> void:
	_on_err = callback


func visit_identifier(ast: _AST.Identifier) -> void:
	if ast.value in _seen:
		var message := "%s is already declared. Can't have multiple identifiers with the same name." % ast.value
		var error := _Error.new(message, ast.line, ast.column)
		_on_err.call(error)
	else:
		_seen[ast.value] = true


func cancel() -> void:
	_seen.clear()


func finish() -> void:
	cancel()

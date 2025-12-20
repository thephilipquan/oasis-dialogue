extends "res://addons/oasis_dialogue/definitions/visitor/visitor.gd"

const _Error := preload("res://addons/oasis_dialogue/definitions/model/error.gd")

var _on_err := Callable()
var _is_default := Callable()

var _seen_default := false


func init_on_err(callback: Callable) -> void:
	_on_err = callback


func init_is_default(callback: Callable) -> void:
	_is_default = callback


func visit_annotation(ast: _AST.Annotation) -> void:
	if not _is_default.call(ast.value):
		return

	if not _seen_default:
		_seen_default = true
	else:
		var error := _Error.new(
				"Can only have 1 default annotation.",
				ast.line,
				ast.column,
		)
		_on_err.call(error)


func cancel() -> void:
	_seen_default = false


func finish() -> void:
	cancel()

extends "res://addons/oasis_dialogue/definitions/visitor/visitor.gd"

const _Error := preload("res://addons/oasis_dialogue/definitions/model/error.gd")

var _on_err := Callable()
var _exclusive_annotation := ""

var _seen_exclusive := false


func init_exclusive_annotation(exclusive_annotation: String) -> void:
	_exclusive_annotation = exclusive_annotation


func init_on_err(callback: Callable) -> void:
	_on_err = callback


func visit_annotation(ast: _AST.Annotation) -> void:
	if ast.value != _exclusive_annotation:
		return

	if _seen_exclusive:
		var error := _Error.new(
				"Can only have 1 default annotation.",
				ast.line,
				ast.column,
		)
		_on_err.call(error)
		return

	_seen_exclusive = true


func cancel() -> void:
	_seen_exclusive = false


func finish() -> void:
	cancel()

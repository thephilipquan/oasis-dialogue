extends "res://addons/oasis_dialogue/definition_panel/visitor/visitor.gd"

const _Error := preload("res://addons/oasis_dialogue/definition_panel/model/error.gd")

var _on_err := Callable()

var _seen: Dictionary[String, bool] = {}

func init_on_err(callback: Callable) -> void:
	_on_err = callback


func visit_declaration(ast: _AST.Declaration) -> void:
	_seen.clear()


func visit_annotation(ast: _AST.Annotation) -> void:
	if ast.value in _seen:
		var error := _Error.new(
			"%s already annotated for this identifier." % ast.value,
			ast.line,
			ast.column,
		)
		_on_err.call(error)
	else:
		_seen[ast.value] = true


func cancel() -> void:
	_seen.clear()


func finish() -> void:
	cancel()

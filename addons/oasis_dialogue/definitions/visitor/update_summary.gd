extends "res://addons/oasis_dialogue/definitions/visitor/visitor.gd"


var _summary := PackedStringArray()
var _update := Callable()


func set_update(callback: Callable) -> void:
	_update = callback


func visit_identifier(ast: _AST.Identifier) -> void:
	_summary.push_back(ast.value)


func cancel() -> void:
	_summary.clear()


func finish() -> void:
	_update.call(_summary.duplicate())
	cancel()

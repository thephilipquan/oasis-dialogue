extends "res://addons/oasis_dialogue/definition_panel/visitor/visitor.gd"

const _Definitions := preload("res://addons/oasis_dialogue/definition_panel/definition_panel.gd")

var _is_viewing_annotations := Callable()
var _is_exclusive_annotation := Callable()
var _update_exclusives := Callable()

var _exclusives := PackedStringArray()
var _viewing_annotations := false
var _next_is_exclusive := false


func init_is_viewing_annotations(callback: Callable) -> void:
	_is_viewing_annotations = callback


func init_is_exclusive_annotation(callback: Callable) -> void:
	_is_exclusive_annotation = callback


func init_update_exclusives(callback: Callable) -> void:
	_update_exclusives = callback


func visit_program(ast: _AST.Program) -> void:
	_viewing_annotations = _is_viewing_annotations.call()


func visit_annotation(ast: _AST.Annotation) -> void:
	if not _viewing_annotations:
		return

	if _is_exclusive_annotation.call(ast.value):
		_next_is_exclusive = true


func visit_identifier(ast: _AST.Identifier) -> void:
	if not _viewing_annotations or not _next_is_exclusive:
		return
	_exclusives.push_back(ast.value)
	_next_is_exclusive = false


func cancel() -> void:
	_exclusives.clear()
	_viewing_annotations = false


func finish() -> void:
	_update_exclusives.call(_exclusives.duplicate())
	cancel()

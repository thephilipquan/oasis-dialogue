extends "res://addons/oasis_dialogue/definitions/visitor/visitor.gd"

const _Definitions := preload("res://addons/oasis_dialogue/definitions/definitions.gd")

var _is_viewing_page := Callable()
var _condition := Callable()
var _update_index := Callable()

var _index := PackedStringArray()
var _viewing_page := false
var _add_current := false


func init_is_viewing_page(callback: Callable) -> void:
	_is_viewing_page = callback


func init_condition(callback: Callable) -> void:
	_condition = callback


func init_update_index(callback: Callable) -> void:
	_update_index = callback


func visit_program(ast: _AST.Program) -> void:
	_viewing_page = _is_viewing_page.call()


func visit_annotation(ast: _AST.Annotation) -> void:
	if not _viewing_page:
		return

	if _condition.call(ast.value):
		_add_current = true


func visit_identifier(ast: _AST.Identifier) -> void:
	if not _viewing_page or not _add_current:
		return
	_index.push_back(ast.value)
	_add_current = false


func cancel() -> void:
	_index.clear()
	_viewing_page = false


func finish() -> void:
	_update_index.call(_index.duplicate())
	cancel()

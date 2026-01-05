extends "res://addons/oasis_dialogue/definitions/visitor/visitor.gd"

const _Definitions := preload("res://addons/oasis_dialogue/definitions/definitions.gd")

var _update_indexes := Callable()

var _indexes: Dictionary[String, PackedStringArray] = {}
var _annotations := PackedStringArray()


func init_update_indexes(callback: Callable) -> void:
	_update_indexes = callback


func visit_declaration(ast: _AST.Declaration) -> void:
	_annotations.clear()


func visit_annotation(ast: _AST.Annotation) -> void:
	_annotations.push_back(ast.value)


func visit_identifier(ast: _AST.Identifier) -> void:
	for a in _annotations:
		var list: PackedStringArray = _indexes.get(a, PackedStringArray())
		if not a in _indexes:
			_indexes[a] = list
		list.push_back(ast.value)


func cancel() -> void:
	_indexes.clear()
	_annotations.clear()


func finish() -> void:
	_update_indexes.call(_indexes.duplicate())
	cancel()

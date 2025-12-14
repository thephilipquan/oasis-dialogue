extends RefCounted

const _AST := preload("res://addons/oasis_dialogue/definition_panel/model/ast.gd")
const _Visitor := preload("res://addons/oasis_dialogue/definition_panel/visitor/visitor.gd")

var _visitors: Array[_Visitor] = []
var _is_valid := false


func set_visitors(visitors: Array[_Visitor]) -> void:
	_visitors = visitors


func accept(ast: _AST.Program) -> void:
	_is_valid = true

	for v in _visitors:
		ast.accept(v)
		if not _is_valid:
			break

	if _is_valid:
		for v in _visitors:
			v.finish()
	else:
		for v in _visitors:
			v.cancel()


func stop() -> void:
	_is_valid = false

extends RefCounted

const _Visitor := preload("res://addons/oasis_dialogue/visitor/visitor.gd")
const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")

var _visitors: Array[_Visitor] = []
var _is_valid := true


func set_visitors(visitors: Array[_Visitor]) -> void:
	_visitors = visitors


func iterate(ast: _AST.AST) -> void:
	_is_valid = true

	var i := 0
	while _is_valid and i < _visitors.size():
		ast.accept(_visitors[i])
		i += 1

	if _is_valid:
		_visitors.map(func(v: _Visitor) -> void: v.finish())
	else:
		_visitors.map(func(v: _Visitor) -> void: v.cancel())


func stop() -> void:
	_is_valid = false

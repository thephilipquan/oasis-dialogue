extends Node

const _Visitor := preload("res://addons/oasis_dialogue/visitor/visitor.gd")
const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")

var _visitors: Array[_Visitor] = []
var _is_valid := true


func _ready() -> void:
	for child in get_children():
		if is_instance_of(child, _Visitor):
			_visitors.push_back(child)


func iterate(ast: _AST.ASTNode) -> void:
	_is_valid = true

	var i := 0
	while _is_valid and i < _visitors.size():
		ast.accept(_visitors[i])
		i += 1

	if _is_valid:
		_visitors.map(func(v: _Visitor): v.finish())
	else:
		_visitors.map(func(v: _Visitor): v.cancel())


func is_valid() -> bool:
	return _is_valid


func stop() -> void:
	_is_valid = false

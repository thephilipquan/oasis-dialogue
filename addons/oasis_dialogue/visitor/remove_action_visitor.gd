extends "res://addons/oasis_dialogue/visitor/visitor.gd"

var _action: _AST.Action = null
var _parent: _AST.Line = null


func _init(action: _AST.Action) -> void:
	_action = action


func visit_line(line: _AST.Line) -> void:
	_parent = line


func visit_action(action: _AST.Action) -> void:
	if _action.equals(action):
		_parent.remove(action)


func cancel() -> void:
	_parent = null


func finish() -> void:
	_parent = null


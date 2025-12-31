extends "res://addons/oasis_dialogue/visitor/visitor.gd"

var _action := ""
var _value := -1

var _parent: _AST.Line = null


func _init(action: String, value: int) -> void:
	_action = action
	_value = value


func visit_line(line: _AST.Line) -> void:
	_parent = line


func visit_action(action: _AST.Action) -> void:
	if (
		action.name == _action
		and action.value
		and action.value.value == _value
	):
		_parent.remove(action)


func cancel() -> void:
	_action = ""
	_value = -1
	_parent = null


func finish() -> void:
	cancel()

extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _Error := preload("res://addons/oasis_dialogue/model/semantic_error.gd")

var _annotations := _Definition.new()
var _conditions := _Definition.new()
var _actions := _Definition.new()
var _on_err := Callable()

var _id := -1


func init_annotation_exists(callback: Callable) -> void:
	_annotations.exists = callback


func init_annotations_enabled(callback: Callable) -> void:
	_annotations.enabled = callback


func init_condition_exists(callback: Callable) -> void:
	_conditions.exists = callback


func init_conditions_enabled(callback: Callable) -> void:
	_conditions.enabled = callback


func init_action_exists(callback: Callable) -> void:
	_actions.exists = callback


func init_actions_enabled(callback: Callable) -> void:
	_actions.enabled = callback


func init_on_err(callback: Callable) -> void:
	_on_err = callback


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_annotation(annotation: _AST.Annotation) -> void:
	# Refactor all 3 visit methods when AST is refactored.
	_validate(_annotations, annotation.name, "annotation", annotation.line, annotation.column)


func visit_condition(condition: _AST.Condition) -> void:
	_validate(_conditions, condition.name, "condition", condition.line, condition.column)


func visit_action(action: _AST.Action) -> void:
	_validate(_actions, action.name, "action", action.line, action.column)


func _validate(definition: _Definition, value: String, type: String, line: int, column: int) -> void:
	if not definition.enabled.call() or definition.exists.call(value):
		return

	var error := _Error.new()
	error.id = _id
	error.message = "%s is not a valid %s." % [value, type]
	error.line = line
	error.column = column
	_on_err.call(error)


func cancel() -> void:
	_id = -1


func finish() -> void:
	cancel()


class _Definition:
	extends RefCounted

	var exists := Callable()
	var enabled := Callable()

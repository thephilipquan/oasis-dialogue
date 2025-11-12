extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _SemanticError := preload("res://addons/oasis_dialogue/model/semantic_error.gd")

var _unique_names: Array[String] = []
var _on_err := Callable()

var _id := -1
var _seen: Array[String] = []


func _init(...conflicting_annotation_names: Array) -> void:
	_unique_names.assign(conflicting_annotation_names)


func init_on_err(on_err: Callable) -> void:
	_on_err = on_err


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_annotation(annotation: _AST.Annotation) -> void:
	if not annotation.name in _unique_names:
		return

	if _seen.size() >= 1:
		var e := _SemanticError.new()
		e.id = _id
		e.message = "Found conflicting types %s" % " and ".join(_unique_names)
		e.line = annotation.line
		e.column = annotation.column
		_on_err.call(e)
		return

	_seen.push_back(annotation.name)


func cancel() -> void:
	_id = -1
	_seen.clear()


func finish() -> void:
	cancel()

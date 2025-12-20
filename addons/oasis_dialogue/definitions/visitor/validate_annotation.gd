extends "res://addons/oasis_dialogue/definitions/visitor/visitor.gd"

const _Error := preload("res://addons/oasis_dialogue/definitions/model/error.gd")

var _get_annotations := Callable()
var _on_err := Callable()


func init_get_annotations(callback: Callable) -> void:
	_get_annotations = callback


func init_on_err(callback: Callable) -> void:
	_on_err = callback


func visit_annotation(ast: _AST.Annotation) -> void:
	var valid_annotations: PackedStringArray = _get_annotations.call()

	var message := ""
	if not valid_annotations:
		message = "There are no annotations for this panel"
	elif valid_annotations.find(ast.value) == -1:
		message = (
				"%s is not a valid annotations. Available annotations are: %s"
				% [ ast.value, ", ".join(valid_annotations)]
		)

	if not message:
		return

	var error := _Error.new(message, ast.line, ast.column)
	_on_err.call(error)

extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _SemanticError := preload("res://addons/oasis_dialogue/model/semantic_error.gd")

var _id := -1
var _on_err := Callable()
var _has_content := false


func _init(on_err: Callable) -> void:
	_on_err = on_err


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_prompt(_prompt: _AST.Prompt) -> void:
	_has_content = true


func visit_response(_response: _AST.Response) -> void:
	_has_content = true


func cancel() -> void:
	_id = -1
	_has_content = false


func finish() -> void:
	if not _has_content:
		var error := _SemanticError.new()
		error.id = _id
		error.message = "Empty branch."
		_on_err.call(error)
		cancel()
		return

	cancel()

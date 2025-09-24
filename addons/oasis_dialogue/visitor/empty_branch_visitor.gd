@tool
extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _SemanticError := preload("res://addons/oasis_dialogue/semantic_error.gd")

signal erred(error: _SemanticError)

var _id := -1


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id
	if branch.prompts or branch.responses:
		return
	var error := _SemanticError.new()
	error.id = _id
	error.message = "Empty branch."
	erred.emit(error)
	stop()

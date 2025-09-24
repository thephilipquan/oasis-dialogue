@tool
extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _Model := preload("res://addons/oasis_dialogue/model/model.gd")

@export
var _model: _Model = null


func visit_branch(branch: _AST.Branch) -> void:
	_model.update_branch(branch)

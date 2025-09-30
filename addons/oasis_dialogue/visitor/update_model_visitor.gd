extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _Model := preload("res://addons/oasis_dialogue/model/model.gd")

var _model: _Model = null


func _init(model: _Model) -> void:
	_model = model


func visit_branch(branch: _AST.Branch) -> void:
	_model.update_branch(branch)

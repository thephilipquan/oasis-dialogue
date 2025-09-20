extends RefCounted

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")

var from := -1
var to := -1
var branch: _AST.Branch = null


func _init(from: int, to: int, branch: _AST.Branch) -> void:
	self.from = from
	self.to = to
	self.branch = branch

extends "res://addons/oasis_dialogue/visitor/visitor.gd"

var _update_model := Callable()

var _ast: _AST.Branch = null


func _init(update_model: Callable) -> void:
	_update_model = update_model


func visit_branch(branch: _AST.Branch) -> void:
	_ast = branch


func cancel() -> void:
	_ast = null


func finish() -> void:
	_update_model.call(_ast)
	cancel()

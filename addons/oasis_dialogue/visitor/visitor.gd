extends Node

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _VisitorIterator := preload("res://addons/oasis_dialogue/visitor/visitor_iterator.gd")


func visit_branch(branch: _AST.Branch) -> void:
	pass
func visit_annotation(annotation: _AST.Annotation) -> void:
	pass
func visit_prompt(prompt: _AST.Prompt) -> void:
	pass
func visit_response(response: _AST.Response) -> void:
	pass
func visit_condition(condition: _AST.Condition) -> void:
	pass
func visit_action(action: _AST.Action) -> void:
	pass
func visit_stringliteral(value: _AST.StringLiteral) -> void:
	pass
func visit_numberliteral(value: _AST.NumberLiteral) -> void:
	pass
func cancel() -> void:
	pass
func finish() -> void:
	pass

func stop() -> void:
	var parent := get_parent() as _VisitorIterator
	if not parent:
		return
	parent.stop()

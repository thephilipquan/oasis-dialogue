@abstract
extends RefCounted

const _AST := preload("res://addons/oasis_dialogue/definition_panel/model/ast.gd")


func visit_program(ast: _AST.Program) -> void:
	pass

func visit_declaration(ast: _AST.Declaration) -> void:
	pass

func visit_annotation(ast: _AST.Annotation) -> void:
	pass

func visit_identifier(ast: _AST.Identifier) -> void:
	pass

func visit_description(ast: _AST.Description) -> void:
	pass

func visit_error(ast: _AST.Error) -> void:
	pass

func cancel() -> void:
	pass

func finish() -> void:
	pass

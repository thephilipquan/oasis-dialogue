## Cleans AST values in response to [signal BranchEdit.branches_dirtied].
extends Node

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const _BranchEdit := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _Unparser := preload("res://addons/oasis_dialogue/visitor/unparser_visitor.gd")

@export
var _graph: _BranchEdit = null
var _unparser: _Unparser = null


func init(unparser: _Unparser) -> void:
	_unparser = unparser


func unparse(ast: _AST.Branch) -> void:
	var branch := _graph.get_branch(ast.id)
	_unparser.unparse(ast)
	branch.set_text(_unparser.get_text())
	_unparser.finish()


func restore_ast(ast: _AST.Branch) -> void:
	#_todo[ast.id] = ast
	pass


func restore_branch(ast: _Branch) -> void:
	pass

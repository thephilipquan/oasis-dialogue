## A class to hold a [VisitorIterator] on the tree.
extends Node

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Visitor := preload("res://addons/oasis_dialogue/visitor/visitor.gd")
const _Iterator := preload("res://addons/oasis_dialogue/visitor/visitor_iterator.gd")

var _visitors: _Iterator = null

func _ready() -> void:
	_visitors = _Iterator.new()


func set_visitors(visitors: Array[_Visitor]) -> void:
	_visitors.set_visitors(visitors)


func visit(ast: _AST.Branch) -> void:
	_visitors.iterate(ast)

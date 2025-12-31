extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const RemoveAction := preload("res://addons/oasis_dialogue/visitor/remove_action_visitor.gd")
const Visitor := preload("res://addons/oasis_dialogue/visitor/visitor.gd")

func test_only_specified_branch_removed() -> void:
	var sut := RemoveAction.new(
			"foo",
			3,
	)

	var ast := AST.Line.new()
	ast.add(AST.Action.new("foo", AST.NumberLiteral.new(2)))
	ast.add(AST.Action.new("foo", AST.NumberLiteral.new(3)))
	ast.add(AST.Action.new("foo", AST.NumberLiteral.new(4)))

	ast.accept(sut)

	ast.accept(TestVisitor.new(
			func(number: AST.NumberLiteral):
				assert_ne(number.value, 3)
	))


class TestVisitor:
	extends Visitor

	var _callback := Callable()

	func _init(callback: Callable) -> void:
		_callback = callback

	func visit_numberliteral(number: AST.NumberLiteral) -> void:
		_callback.call(number)

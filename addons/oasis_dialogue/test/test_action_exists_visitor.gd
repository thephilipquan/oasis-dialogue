extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const ActionExistsVisitor := preload("res://addons/oasis_dialogue/model/action_exists_visitor.gd")

var sut: ActionExistsVisitor = null


func after_each() -> void:
	sut = null


func test_action_exists() -> void:
	sut = ActionExistsVisitor.new(
		func(s: String): return true,
		func(id: int, message: String): fail_test(""),
	)
	var ast := AST.Branch.new(
		0,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("hello world"),
				[
					AST.Action.new("foo", null),
				],
			),
		],
		[],
	)

	ast.accept(sut)

	pass_test("")


func test_action_not_exists() -> void:
	sut = ActionExistsVisitor.new(
		func(s: String): return false,
		func(id: int, message: String): pass_test(""),
	)
	var ast := AST.Branch.new(
		0,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("hello world"),
				[
					AST.Action.new("foo", null),
				],
			),
		],
		[],
	)

	ast.accept(sut)

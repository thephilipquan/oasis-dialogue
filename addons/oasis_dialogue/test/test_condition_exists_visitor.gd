extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const ConditionExistsVisitor := preload("res://addons/oasis_dialogue/model/condition_exists_visitor.gd")

var sut: ConditionExistsVisitor = null


func after_each() -> void:
	sut = null


func test_condition_exists() -> void:
	sut = ConditionExistsVisitor.new(
		func(s: String): return true,
		func(id: int, message: String): fail_test(""),
	)
	var ast := AST.Branch.new(
		0,
		[],
		[
			AST.Prompt.new(
				[
					AST.Condition.new("foo", null),
				],
				AST.StringLiteral.new("hello world"),
				[],
			),
		],
		[],
	)
	ast.accept(sut)

	pass_test("")


func test_no_branch_action() -> void:
	sut = ConditionExistsVisitor.new(
		func(s: String): return false,
		func(id: int, message: String): pass_test(""),
	)
	var ast := AST.Branch.new(
		0,
		[],
		[
			AST.Prompt.new(
				[
					AST.Condition.new("foo", null),
				],
				AST.StringLiteral.new("hello world"),
				[],
			),
		],
		[],
	)
	ast.accept(sut)


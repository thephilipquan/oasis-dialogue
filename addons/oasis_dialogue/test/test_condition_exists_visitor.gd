extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const ConditionExists := preload("res://addons/oasis_dialogue/visitor/condition_exists_visitor.gd")

var sut: ConditionExists = null


func after_each() -> void:
	sut = null


func test_condition_exists() -> void:
	sut = ConditionExists.new(func(s: String): return true)
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
	watch_signals(sut)

	ast.accept(sut)

	assert_signal_not_emitted(sut.erred)


func test_no_branch_action() -> void:
	sut = ConditionExists.new(func(s: String): return false)
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
	watch_signals(sut)

	ast.accept(sut)

	assert_signal_emitted(sut.erred)

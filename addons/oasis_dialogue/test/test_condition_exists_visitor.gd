extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const ConditionExistsVisitor := preload("res://addons/oasis_dialogue/model/condition_exists_visitor.gd")

var sut: ConditionExistsVisitor = null


func before_each() -> void:
	sut = add_child_autofree(ConditionExistsVisitor.new())


func test_condition_exists() -> void:
	sut.init(func(s: String): return true)
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
	sut.init(func(s: String): return false)
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

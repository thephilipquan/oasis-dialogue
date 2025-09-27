extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const ActionExists := preload("res://addons/oasis_dialogue/visitor/action_exists_visitor.gd")

var sut: ActionExists = null


func after_each() -> void:
	sut = null


func test_action_exists() -> void:
	sut = ActionExists.new(func(s: String): return true)
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
	watch_signals(sut)

	ast.accept(sut)

	assert_signal_not_emitted(sut.erred)


func test_action_not_exists() -> void:
	sut = ActionExists.new(func(s: String): return false)
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
	watch_signals(sut)

	ast.accept(sut)

	assert_signal_emitted(sut.erred)

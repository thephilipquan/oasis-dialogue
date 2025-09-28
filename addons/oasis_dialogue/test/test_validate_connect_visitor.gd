extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const ValidateConnect := preload("res://addons/oasis_dialogue/visitor/validate_connect_visitor.gd")
const Global := preload("res://addons/oasis_dialogue/global.gd")

const CONNECT_KEYWORD := "foo"

var sut: ValidateConnect = null


func after_each() -> void:
	sut = null


func test_normal() -> void:
	sut = ValidateConnect.new(
		CONNECT_KEYWORD,
		func(): fail_test(""),
	)
	var ast := AST.Branch.new(
		2,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("text"),
				[
					AST.Action.new(CONNECT_KEYWORD, AST.NumberLiteral.new(4)),
					AST.Action.new(CONNECT_KEYWORD, AST.NumberLiteral.new(6)),
				],
			),
		],
		[],
	)
	watch_signals(sut)

	ast.accept(sut)
	sut.finish()

	assert_signal_not_emitted(sut.erred)


func test_no_branch_action() -> void:
	sut = ValidateConnect.new(
		CONNECT_KEYWORD,
		func(): fail_test("")
	)
	var ast := AST.Branch.new(
		1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("text"),
				[
					AST.Action.new(CONNECT_KEYWORD + "bar", AST.NumberLiteral.new(4)),
				],
			),
		],
		[],
	)
	watch_signals(sut)

	ast.accept(sut)
	sut.finish()

	assert_signal_not_emitted(sut.erred)


func test_missing_number() -> void:
	sut = ValidateConnect.new(
		CONNECT_KEYWORD,
		func(): pass_test("")
	)
	var ast := AST.Branch.new(
		2,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("text"),
				[
					AST.Action.new(CONNECT_KEYWORD, null),
				],
			),
		],
		[],
	)
	watch_signals(sut)

	ast.accept(sut)

	assert_signal_emitted(sut.erred)


func test_branching_to_itself() -> void:
	sut = ValidateConnect.new(
		CONNECT_KEYWORD,
		func(): pass_test(""),
	)
	var ast := AST.Branch.new(
		4,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("text"),
				[
					AST.Action.new(CONNECT_KEYWORD, AST.NumberLiteral.new(4)),
				],
			),
		],
		[],
	)
	watch_signals(sut)

	ast.accept(sut)

	assert_signal_emitted(sut.erred)


func test_resets_members_on_cancel() -> void:
	sut = ValidateConnect.new(
		CONNECT_KEYWORD,
		func(a: int, to: Array[int]): pass,
	)
	var ast := AST.Branch.new(
		2,
		[],
		[],
		[],
	)

	ast.accept(sut)
	sut.cancel()

	assert_eq(sut._id, -1)


func test_resets_members_on_finish() -> void:
	sut = ValidateConnect.new(
		CONNECT_KEYWORD,
		func(a: int, to: Array[int]): pass,
	)
	var ast := AST.Branch.new(
		2,
		[],
		[],
		[],
	)

	ast.accept(sut)
	sut.finish()

	assert_eq(sut._id, -1)

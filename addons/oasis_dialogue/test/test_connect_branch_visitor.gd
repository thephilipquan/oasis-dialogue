extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const ConnectBranchVisitor := preload("res://addons/oasis_dialogue/model/connect_branch_visitor.gd")
const Global := preload("res://addons/oasis_dialogue/global.gd")

var sut: ConnectBranchVisitor = null


func before_each() -> void:
	sut = add_child_autofree(ConnectBranchVisitor.new())


func test_normal() -> void:
	sut.init(
		"foo",
		func(a: int, to: Array[int]):
			assert_eq_deep(to, [4, 6]),
	)
	var ast := AST.Branch.new(
		2,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("text"),
				[
					AST.Action.new("foo", AST.NumberLiteral.new(4)),
					AST.Action.new("foo", AST.NumberLiteral.new(6)),
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
	sut.init(
		"foo",
		func(a: int, b: Array[int]): assert_eq_deep(b, []),
	)
	var ast := AST.Branch.new(
		1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("text"),
				[
					AST.Action.new("give_gold", AST.NumberLiteral.new(4)),
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
	sut.init(
		"foo",
		func(id: int, to: Array[int]): fail_test("finish will not be called"),
	)
	var ast := AST.Branch.new(
		2,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("text"),
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


func test_branching_to_itself() -> void:
	sut.init(
		"foo",
		func(id: int, to: Array[int]): fail_test("finish will not be called"),
	)
	var ast := AST.Branch.new(
		4,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("text"),
				[
					AST.Action.new("foo", AST.NumberLiteral.new(4)),
				],
			),
		],
		[],
	)
	watch_signals(sut)

	ast.accept(sut)

	assert_signal_emitted(sut.erred)


func test_duplicate_list_is_passed() -> void:
	var got: Array[int] = []
	sut.init(
		"foo",
		func(a: int, to: Array[int]): assert_ne(sut._to_branches, got),
	)
	var ast := AST.Branch.new(
		2,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("text"),
				[
					AST.Action.new("foo", AST.NumberLiteral.new(4)),
					AST.Action.new("foo", AST.NumberLiteral.new(6)),
				],
			),
		],
		[],
	)
	watch_signals(sut)

	ast.accept(sut)
	sut.finish()

	assert_signal_not_emitted(sut.erred)


func test_calls_connect_branch_even_if_to_branches_is_empty() -> void:
	sut.init(
		"foo",
		func(a: int, b: Array[int]): assert_eq_deep(b, []),
	)
	var ast := AST.Branch.new(
		1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("text"),
				[
					AST.Action.new("give_gold", AST.NumberLiteral.new(4)),
				],
			),
		],
		[],
	)
	watch_signals(sut)

	ast.accept(sut)
	sut.finish()

	assert_signal_not_emitted(sut.erred)


func test_resets_members_after_cancel() -> void:
	sut.init(
		"foo",
		func(a: int, to: Array[int]): pass,
	)
	var ast := AST.Branch.new(
		2,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("text"),
				[
					AST.Action.new("foo", AST.NumberLiteral.new(4)),
					AST.Action.new("foo", AST.NumberLiteral.new(6)),
				],
			),
		],
		[],
	)

	ast.accept(sut)
	sut.cancel()

	assert_eq(sut._id, -1)
	assert_eq_deep(sut._to_branches, [])


func test_resets_members_after_finish() -> void:
	sut.init(
		"foo",
		func(a: int, to: Array[int]): pass,
	)
	var ast := AST.Branch.new(
		2,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("text"),
				[
					AST.Action.new("foo", AST.NumberLiteral.new(4)),
					AST.Action.new("foo", AST.NumberLiteral.new(6)),
				],
			),
		],
		[],
	)

	ast.accept(sut)
	sut.finish()

	assert_eq(sut._id, -1)
	assert_eq_deep(sut._to_branches, [])

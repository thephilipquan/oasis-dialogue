extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const ConnectBranchVisitor := preload("res://addons/oasis_dialogue/model/connect_branch_visitor.gd")
const Global := preload("res://addons/oasis_dialogue/global.gd")

var sut: ConnectBranchVisitor = null


func after_each() -> void:
	sut = null


func test_normal() -> void:
	sut = ConnectBranchVisitor.new(
		"foo",
		func(a: int, to: Array[int]):
			assert_eq_deep(to, [4, 6]),
		func(id: int, message: String): fail_test("on_err should not be called"),
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


func test_no_branch_action() -> void:
	sut = ConnectBranchVisitor.new(
		"foo",
		func(a: int, b: Array[int]): assert_eq_deep(b, []),
		func(id: int, message: String): fail_test("on_err should not be called"),
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

	ast.accept(sut)
	sut.finish()


func test_missing_number() -> void:
	sut = ConnectBranchVisitor.new(
		"foo",
		func(id: int, to: Array[int]): fail_test("finish will not be called"),
		func(id: int, message: String): pass_test("on_err was called"),
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

	ast.accept(sut)


func test_branching_to_itself() -> void:
	sut = ConnectBranchVisitor.new(
		"foo",
		func(id: int, to: Array[int]): fail_test("finish will not be called"),
		func(id: int, message: String): pass_test("on_err was called"),
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

	ast.accept(sut)


func test_duplicate_list_is_passed() -> void:
	var got: Array[int] = []
	sut = ConnectBranchVisitor.new(
		"foo",
		func(a: int, to: Array[int]): assert_ne(sut._to_branches, got),
		func(id: int, message: String): fail_test("on_err should not be called"),
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


func test_calls_connect_branch_even_if_to_branches_is_empty() -> void:
	sut = ConnectBranchVisitor.new(
		"foo",
		func(a: int, b: Array[int]): assert_eq_deep(b, []),
		func(id: int, message: String): fail_test("on_err should not be called"),
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

	ast.accept(sut)
	sut.finish()


func test_resets_members_after_cancel() -> void:
	sut = ConnectBranchVisitor.new(
		"foo",
		func(a: int, to: Array[int]): pass,
		func(id: int, message: String): pass,
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
	sut = ConnectBranchVisitor.new(
		"foo",
		func(a: int, to: Array[int]): pass,
		func(id: int, message: String): pass,
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

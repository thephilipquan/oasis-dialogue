extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const EmptyBranchVisitor := preload("res://addons/oasis_dialogue/model/empty_branch_visitor.gd")

var sut: EmptyBranchVisitor = null


func after_each() -> void:
	sut = null


func test_non_empty() -> void:
	sut = EmptyBranchVisitor.new(
		fail_test.bind("stop_iterator should not be called"),
		func(id: int, message: String): fail_test("on_err should not be called"),
	)
	var ast := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new([], AST.StringLiteral.new("hey there"), []),
		],
		[],
	)

	ast.accept(sut)

	pass_test("")


func test_empty() -> void:
	sut = EmptyBranchVisitor.new(
		pass_test.bind(""),
		func(id: int, message: String): pass_test(""),
	)
	var ast := AST.Branch.new(-1, [], [], [])

	ast.accept(sut)

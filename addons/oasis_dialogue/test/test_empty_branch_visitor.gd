extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const EmptyBranch := preload("res://addons/oasis_dialogue/visitor/empty_branch_visitor.gd")

var sut: EmptyBranch = null


func after_each() -> void:
	sut = null


func test_non_empty() -> void:
	sut = EmptyBranch.new(fail_test.bind(""))
	var ast := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new([], AST.StringLiteral.new("hey there"), []),
		],
		[],
	)
	watch_signals(sut)

	ast.accept(sut)

	assert_signal_not_emitted(sut.erred)


func test_empty_call_stop() -> void:
	sut = EmptyBranch.new(pass_test.bind(""))
	var ast := AST.Branch.new(-1, [], [], [])
	watch_signals(sut)

	ast.accept(sut)

	assert_signal_emitted(sut.erred)

extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const EmptyBranchVisitor := preload("res://addons/oasis_dialogue/model/empty_branch_visitor.gd")

var sut: EmptyBranchVisitor = null


func before_each() -> void:
	sut = add_child_autofree(partial_double(EmptyBranchVisitor).new())


func test_non_empty() -> void:
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


func test_empty() -> void:
	stub(sut.stop).to_do_nothing()
	var ast := AST.Branch.new(-1, [], [], [])
	watch_signals(sut)

	ast.accept(sut)

	assert_signal_emitted(sut.erred)
	assert_called(sut.stop)

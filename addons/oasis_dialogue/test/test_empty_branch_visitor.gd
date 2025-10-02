extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const EmptyBranch := preload("res://addons/oasis_dialogue/visitor/empty_branch_visitor.gd")


func test_empty_calls_on_err() -> void:
	var sut := EmptyBranch.new(func(e): pass_test(""))
	var ast := AST.Branch.new()

	ast.accept(sut)
	sut.finish()


func test_prompt_exists_does_nothing() -> void:
	var sut := EmptyBranch.new(func(e): fail_test(""))
	var ast := AST.Branch.new()

	var prompt := AST.Prompt.new()
	prompt.add(AST.Action.new("foo"))
	ast.add(prompt)

	ast.accept(sut)
	sut.finish()

	pass_test("")


func test_response_exists_does_nothing() -> void:
	var sut := EmptyBranch.new(func(e): fail_test(""))
	var ast := AST.Branch.new()

	var response := AST.Response.new()
	response.add(AST.Action.new("foo"))
	ast.add(response)

	ast.accept(sut)
	sut.finish()

	pass_test("")


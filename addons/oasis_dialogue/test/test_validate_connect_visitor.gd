extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const ValidateConnect := preload("res://addons/oasis_dialogue/visitor/validate_connect_visitor.gd")


func test_action_with_value_does_nothing() -> void:
	var sut := ValidateConnect.new(
		"foo",
		func(): fail_test(""),
	)
	var ast := AST.Branch.new(2)
	ast.add(AST.Action.new("foo", AST.NumberLiteral.new(3)))

	ast.accept(sut)

	pass_test("")


func test_no_branch_action_does_nothing() -> void:
	var sut := ValidateConnect.new(
		"foo",
		func(): fail_test(""),
	)
	var ast := AST.Branch.new(2)
	ast.add(AST.Action.new("bar", AST.NumberLiteral.new(3)))

	ast.accept(sut)
	sut.finish()

	pass_test("")


func test_missing_number_calls_on_err() -> void:
	var sut := ValidateConnect.new(
		"foo",
		func(e): pass_test(""),
	)
	var ast := AST.Branch.new(2)
	ast.add(AST.Action.new("foo"))

	ast.accept(sut)


func test_branching_to_itself_calls_on_err() -> void:
	var sut := ValidateConnect.new(
		"foo",
		func(e): pass_test(""),
	)
	var ast := AST.Branch.new(2)
	ast.add(AST.Action.new("foo", AST.NumberLiteral.new(2)))

	ast.accept(sut)

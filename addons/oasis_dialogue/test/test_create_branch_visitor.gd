extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const CreateBranch := preload("res://addons/oasis_dialogue/visitor/create_branch_visitor.gd")


func test_calls_add_branch_with_matching_action_values() -> void:
	var got := []
	var sut := CreateBranch.new(
			"foo",
			func(id: int): return 2 <= id and id <= 4,
			func(id: int): got.push_back(id),
	)
	var ast := AST.Line.new()
	ast.add(AST.Action.new("foo", AST.NumberLiteral.new(0)))
	ast.add(AST.Action.new("foo", AST.NumberLiteral.new(3)))
	ast.add(AST.Action.new("foo", AST.NumberLiteral.new(6)))
	ast.add(AST.Action.new("foo", AST.NumberLiteral.new(4)))

	ast.accept(sut)
	sut.finish()

	assert_eq_deep(got, [0, 6])

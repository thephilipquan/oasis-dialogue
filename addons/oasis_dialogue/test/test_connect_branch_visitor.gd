extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const ConnectBranch := preload("res://addons/oasis_dialogue/visitor/connect_branch_visitor.gd")


func test_valid_connections_emits_non_empty_list() -> void:
	var sut := ConnectBranch.new(
			"foo",
			func(id: int, to: Array[int], is_interactive: bool):
				assert_eq(id, 8)
				assert_eq_deep(to, [2, 3]),
			func(): return false,
	)
	var ast := AST.Branch.new(8)
	ast.add(AST.Action.new("bar"))
	ast.add(AST.Action.new("foo", AST.NumberLiteral.new(2)))
	ast.add(AST.Action.new("foo", AST.NumberLiteral.new(3)))

	ast.accept(sut)
	sut.finish()


func test_no_connecting_actions_calls_connect_with_empty_list() -> void:
	var sut := ConnectBranch.new(
			"foo",
			func(id: int, to: Array[int], is_interactive: bool):
				assert_eq_deep(to, []),
			func(): return false,
	)
	var ast := AST.Branch.new(8)
	ast.add(AST.Action.new("bar", AST.NumberLiteral.new(2)))
	ast.add(AST.Action.new("bar", AST.NumberLiteral.new(3)))

	ast.accept(sut)
	sut.finish()

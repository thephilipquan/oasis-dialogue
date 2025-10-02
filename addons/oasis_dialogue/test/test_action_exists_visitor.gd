extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const ActionExists := preload("res://addons/oasis_dialogue/visitor/action_exists_visitor.gd")
const SemanticError := preload("res://addons/oasis_dialogue/semantic_error.gd")


func test_visit_existing_action_does_nothing() -> void:
	var sut := ActionExists.new(
			func(s): return true,
			func(e): fail_test(""),
	)
	var ast := AST.Action.new("foo")

	ast.accept(sut)
	pass_test("")



func test_visit_non_existing_action_calls_err() -> void:
	var sut := ActionExists.new(
			func(s): return false,
			func(e: SemanticError): assert_eq(e.id, 3),
	)
	var ast := AST.Branch.new(3)
	ast.add(AST.Action.new("foo"))

	ast.accept(sut)

extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const ConditionExists := preload("res://addons/oasis_dialogue/visitor/condition_exists_visitor.gd")
const SemanticError := preload("res://addons/oasis_dialogue/model/semantic_error.gd")


func test_visit_existing_condition_does_nothing() -> void:
	var sut := ConditionExists.new(
			func(s): return true,
			func(e): fail_test(""),
	)
	var ast := AST.Condition.new("foo")

	ast.accept(sut)

	pass_test("")


func test_visit_non_existing_condition_calls_err() -> void:
	var sut := ConditionExists.new(
			func(s): return false,
			func(e: SemanticError): assert_eq(e.id, 8),
	)
	var ast := AST.Branch.new(8)
	ast.add(AST.Condition.new("foo"))

	ast.accept(sut)


extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const UniqueType := preload("res://addons/oasis_dialogue/visitor/unique_type_visitor.gd")
const SemanticError := preload("res://addons/oasis_dialogue/model/semantic_error.gd")


func test_only_one_type_does_not_call_on_err() -> void:
	var sut := UniqueType.new("foo", "bar")
	sut.init_on_err(func(e): fail_test(""))
	var ast := AST.Branch.new(-1,
			[
				AST.Annotation.new("foo"),
				AST.Annotation.new("baz"),
			],
	)

	ast.accept(sut)
	sut.finish()

	pass_test("")


func test_conflicting_types_calls_on_err() -> void:
	var sut := UniqueType.new("foo", "bar")
	sut.init_on_err(func(e): assert_eq(e.id, 8))
	var ast := AST.Branch.new(8,
			[
				AST.Annotation.new("foo"),
				AST.Annotation.new("bar"),
			],
	)

	ast.accept(sut)
	sut.finish()

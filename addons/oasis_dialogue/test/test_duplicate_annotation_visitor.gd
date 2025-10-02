extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const DuplicateAnnotation := preload("res://addons/oasis_dialogue/visitor/duplicate_annotation_visitor.gd")


func test_unique_annotations_does_nothing() -> void:
	var sut := DuplicateAnnotation.new(func(e): fail_test(""))
	var ast := AST.Branch.new()
	ast.add(AST.Annotation.new("foo"))
	ast.add(AST.Annotation.new("bar"))

	ast.accept(sut)

	pass_test("")


func test_same_annotations_calls_on_err() -> void:
	var sut := DuplicateAnnotation.new(func(e): pass_test(""))
	var ast := AST.Branch.new()
	ast.add(AST.Annotation.new("foo"))
	ast.add(AST.Annotation.new("foo"))

	ast.accept(sut)

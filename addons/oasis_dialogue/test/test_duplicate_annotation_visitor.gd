extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const DuplicateAnnotationVisitor := preload("res://addons/oasis_dialogue/model/duplicate_annotation_visitor.gd")

var sut: DuplicateAnnotationVisitor = null


func after_each() -> void:
	sut = null


func test_duplicates() -> void:
	sut = DuplicateAnnotationVisitor.new(
		func(): pass_test(""),
		func(id: int, message: String): pass_test(""),
	)
	var ast := AST.Branch.new(
		-1,
		[
			AST.Annotation.new("rng", null),
			AST.Annotation.new("unique", null),
			AST.Annotation.new("rng", null),
		],
		[],
		[],
	)

	ast.accept(sut)


func test_no_duplicates() -> void:
	sut = DuplicateAnnotationVisitor.new(
		func(): fail_test("stop_iterator should not be called"),
		func(id: int, message: String): fail_test("on_err should not be called"),
	)
	var ast := AST.Branch.new(
		-1,
		[
			AST.Annotation.new("rng", null),
			AST.Annotation.new("unique", null),
		],
		[],
		[],
	)

	ast.accept(sut)

	pass_test("")

extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const DuplicateAnnotation := preload("res://addons/oasis_dialogue/visitor/duplicate_annotation_visitor.gd")

var sut: DuplicateAnnotation = null


func after_each() -> void:
	sut = null


func test_duplicates() -> void:
	sut = DuplicateAnnotation.new(pass_test.bind(""))
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
	watch_signals(sut)

	ast.accept(sut)

	assert_signal_emitted(sut.erred)


func test_no_duplicates() -> void:
	sut = DuplicateAnnotation.new(fail_test.bind(""))
	var ast := AST.Branch.new(
		-1,
		[
			AST.Annotation.new("rng", null),
			AST.Annotation.new("unique", null),
		],
		[],
		[],
	)
	watch_signals(sut)

	ast.accept(sut)

	assert_signal_not_emitted(sut.erred)

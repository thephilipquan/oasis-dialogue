extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const DuplicateAnnotationVisitor := preload("res://addons/oasis_dialogue/model/duplicate_annotation_visitor.gd")

var sut: DuplicateAnnotationVisitor = null


func before_each() -> void:
	sut = add_child_autofree(partial_double(DuplicateAnnotationVisitor).new())


func test_duplicates() -> void:
	stub(sut.stop).to_do_nothing()
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
	assert_called(sut.stop)


func test_no_duplicates() -> void:
	stub(sut.stop).to_do_nothing()
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


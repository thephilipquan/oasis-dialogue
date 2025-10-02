extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const UpdateModel := preload("res://addons/oasis_dialogue/visitor/update_model_visitor.gd")
const Model := preload("res://addons/oasis_dialogue/model/model.gd")


func test_passes_ast_on_finish() -> void:
	var ast := AST.Branch.new()
	var sut := UpdateModel.new(func(x): assert_same(x, ast))

	ast.accept(sut)
	sut.finish()

extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const UpdateModel := preload("res://addons/oasis_dialogue/model/update_model_visitor.gd")
const Model := preload("res://addons/oasis_dialogue/model/model.gd")

var sut: UpdateModel = null
var model: Model = null


func before_each() -> void:
	model = double(Model).new()
	sut = add_child_autofree(UpdateModel.new())
	sut._model = model


func after_each() -> void:
	sut.finish()


func test_normal() -> void:
	var ast := AST.Branch.new(
		-1,
		[],
		[],
		[],
	)
	watch_signals(sut)

	ast.accept(sut)

	assert_called(model, "update_branch", [ast])

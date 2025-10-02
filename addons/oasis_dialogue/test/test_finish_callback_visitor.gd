extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const FinishCallback := preload("res://addons/oasis_dialogue/visitor/finish_callback_visitor.gd")


func test_finish_calls_callback_with_branch_id() -> void:
	var sut := FinishCallback.new(func(id: int): assert_eq(id, 7))
	var ast := AST.Branch.new(7)
	ast.accept(sut)
	sut.finish()

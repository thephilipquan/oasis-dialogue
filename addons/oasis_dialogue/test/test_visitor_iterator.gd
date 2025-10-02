extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const Visitor := preload("res://addons/oasis_dialogue/visitor/visitor.gd")
const Iterator := preload("res://addons/oasis_dialogue/visitor/visitor_iterator.gd")

var sut: Iterator = null


func before_each() -> void:
	sut = Iterator.new()


func test_set_visitors() -> void:
	var visitors: Array[Visitor] = [
		double(Visitor).new(),
		double(Visitor).new(),
	]
	sut.set_visitors(visitors)

	assert_eq_deep(sut._visitors, visitors)


func test_stop() -> void:
	sut._is_valid = true

	sut.stop()

	assert_false(sut._is_valid)


func test_iterate_resets_validity() -> void:
	sut._is_valid = false
	var ast := AST.Branch.new(-1)

	sut.iterate(ast)

	assert_true(sut._is_valid)


func test_calls_visitor_finish() -> void:
	var visitor: Visitor = double(Visitor).new()
	sut.set_visitors([
		visitor,
	])
	var ast := AST.Branch.new(-1)

	sut.iterate(ast)

	assert_called(visitor.finish)
	assert_not_called(visitor.cancel)


func test_calls_visitor_cancel_when_stopped() -> void:
	var visitor: Visitor = double(Visitor).new()
	sut.set_visitors([
		visitor,
	])
	var ast := AST.Branch.new(-1)
	stub(visitor.visit_branch).to_call(func(b: AST.Branch): sut.stop())

	sut.iterate(ast)

	assert_called(visitor.cancel)
	assert_not_called(visitor.finish)

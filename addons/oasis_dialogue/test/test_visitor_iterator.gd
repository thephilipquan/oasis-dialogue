extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const Visitor := preload("res://addons/oasis_dialogue/visitor/visitor.gd")
const Iterator := preload("res://addons/oasis_dialogue/visitor/visitor_iterator.gd")

var sut: Iterator = null


func before_each() -> void:
	sut = Iterator.new()


func test_ready_sets_visitors() -> void:
	sut.add_child(double(Visitor).new())
	sut.add_child(Node.new())
	sut.add_child(Node2D.new())
	sut.add_child(double(Visitor).new())
	add_child_autofree(sut)

	assert_eq(sut._visitors.size(), 2)


func test_stop() -> void:
	add_child_autofree(sut)
	assert_true(sut.is_valid())

	sut.stop()

	assert_false(sut.is_valid())


func test_iterate_resets_validity() -> void:
	add_child_autofree(sut)
	sut._is_valid = false
	var ast := AST.Branch.new(-1, [], [], [])

	sut.iterate(ast)

	assert_true(sut.is_valid())


func test_calls_visitor_finish() -> void:
	var visitor: Visitor = double(Visitor).new()
	sut.add_child(visitor)
	add_child_autofree(sut)
	var ast := AST.Branch.new(-1, [], [], [])

	sut.iterate(ast)

	assert_called(visitor.finish)
	assert_not_called(visitor.cancel)


func test_calls_visitor_cancel_when_stopped() -> void:
	var visitor: Visitor = double(Visitor).new()
	sut.add_child(visitor)
	add_child_autofree(sut)
	var ast := AST.Branch.new(-1, [], [], [])
	stub(visitor.visit_branch).to_call(func(b: AST.Branch): sut.stop())

	sut.iterate(ast)

	assert_called(visitor.cancel)
	assert_not_called(visitor.finish)

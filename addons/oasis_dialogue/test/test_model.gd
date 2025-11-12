extends GutTest

const Model := preload("res://addons/oasis_dialogue/model/model.gd")
const OasisFile := preload("res://addons/oasis_dialogue/io/oasis_file.gd")

var sut: Model = null


func before_each() -> void:
	sut = add_child_autofree(Model.new())


func test_set_conditions() -> void:
	sut.set_conditions(["a", "b"])
	assert_true(sut.has_condition("a"))
	assert_true(sut.has_condition("b"))
	assert_false(sut.has_condition("c"))


func test_set_conditions_overwrites_conditions() -> void:
	sut.set_conditions(["a"])
	sut.set_conditions(["c"])
	assert_false(sut.has_condition("a"))
	assert_true(sut.has_condition("c"))


func test_load_conditions_restores_saved_data() -> void:
	sut.set_conditions(["a", "b"])
	var file := OasisFile.new()
	sut.save_conditions(file)

	before_each()
	sut.load_conditions(file)

	assert_true(sut.has_condition("a"))
	assert_true(sut.has_condition("b"))


func test_set_actions() -> void:
	sut.set_actions(["a", "b"])
	assert_true(sut.has_action("a"))
	assert_true(sut.has_action("b"))
	assert_false(sut.has_action("c"))


func test_set_actions_overwrites_actions() -> void:
	sut.set_actions(["a"])
	sut.set_actions(["c"])
	assert_false(sut.has_action("a"))
	assert_true(sut.has_action("c"))


func test_load_actions_restores_saved_data() -> void:
	sut.set_actions(["a", "b"])
	var file := OasisFile.new()
	sut.save_actions(file)

	before_each()
	sut.load_actions(file)

	assert_true(sut.has_action("a"))
	assert_true(sut.has_action("b"))

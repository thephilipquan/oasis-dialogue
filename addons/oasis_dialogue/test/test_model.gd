extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const Model := preload("res://addons/oasis_dialogue/model/model.gd")

var sut: Model = null


func before_each() -> void:
	sut = Model.new()


func test_set_conditions() -> void:
	var conditions: Array[String] = [
		"has_gold",
		"is_day",
	]
	sut.set_conditions(conditions)
	assert_eq_deep(sut._conditions, conditions)


func test_has_condition() -> void:
	sut.set_conditions([
		"has_gold",
	])
	assert_true(sut.has_condition("has_gold"))
	assert_false(sut.has_condition("is_day"))


func test_set_actions() -> void:
	var actions: Array[String] = [
		"foo",
		"bar",
	]
	sut.set_actions(actions)
	assert_eq_deep(sut._actions, actions)


func test_has_action() -> void:
	sut.set_actions([
		"foo",
	])
	assert_true(sut.has_action("foo"))
	assert_false(sut.has_action("bar"))


func test_is_active() -> void:
	assert_false(sut.is_active())
	sut.add_character("foo")
	sut.switch_character("foo")
	assert_true(sut.is_active())


func test_add_character() -> void:
	sut.add_character("foo")
	assert_true("foo" in sut.get_characters().keys())


func test_add_character_has_no_branches() -> void:
	sut.add_character("fred")
	assert_eq(sut.get_characters()["fred"].branches.size(), 0)


func test_get_character_names() -> void:
	sut.add_character("foo")
	sut.add_character("bar")
	assert_eq_deep(sut.get_characters().keys(), ["foo", "bar"])


func test_switch_and_get_active_character() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")
	assert_eq(sut.get_active_character(), "fred")


func test_add_branch_with_no_characters() -> void:
	watch_signals(sut)

	sut.add_branch()

	assert_signal_not_emitted(sut.branch_added)


func test_add_branch_with_no_active() -> void:
	sut.add_character("fred")
	watch_signals(sut)

	sut.add_branch()

	assert_signal_not_emitted(sut.branch_added)


func test_add_branch() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")

	sut.add_branch()

	assert_eq(sut.get_branches().size(), 1)


func test_add_branch_emits_branch_added() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")
	watch_signals(sut)

	sut.add_branch()

	assert_signal_emitted_with_parameters(sut.branch_added, [0])


func test_update_branch() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")
	sut.add_branch()
	var annotations: Array[AST.ASTNode] = [
		AST.Annotation.new("rng", null),
	]
	var ast := AST.Branch.new(0, annotations, [], [])

	sut.update_branch(0, ast)

	var got := sut.get_branches()
	if not got:
		fail_test("expected branches, got none")
	else:
		assert_eq(got[0], ast)


func test_remove_branch() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")
	sut.add_named_branch(3)
	sut.add_named_branch(8)
	sut.add_named_branch(13)

	sut.remove_branch(8)

	assert_false(sut.has_branch(8))


func test_has_branch_exists() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")
	sut.add_named_branch(3)

	assert_true(sut.has_branch(3))


func test_has_branch_not_exists() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")
	sut.add_named_branch(3)

	assert_false(sut.has_branch(2))


func test_has_branches() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")
	sut.add_branch()
	assert_true(sut.has_branches())


func test_has_no_branches() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")
	assert_false(sut.has_branches())


func test_get_branch() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")
	sut.add_branch()

	var ast := sut.get_branch(0)
	assert_ne(ast, null)


func test_get_branches() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")
	sut.add_branch()
	assert_eq(sut.get_branches().size(), 1)


func test_remove_character() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")
	sut.remove_character()
	assert_true(not "fred" in sut.get_characters().keys())


func test_remove_character_clears_active() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")
	sut.remove_character()
	assert_eq(sut.get_active_character(), "")


func test_rename_character() -> void:
	sut.add_character("foo")
	sut.switch_character("foo")

	sut.rename_character("bar")

	assert_eq(sut.get_active_character(), "bar")
	assert_false("foo" in sut.get_characters().keys())
	assert_true("bar" in sut.get_characters().keys())


func test_remove_character_with_branches() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")
	sut.add_branch()
	sut.remove_character()
	assert_eq(sut.get_active_character(), "fred")
	assert_true("fred" in sut.get_characters().keys())


func test_force_remove_character() -> void:
	sut.add_character("fred")
	sut.switch_character("fred")
	sut.add_branch()
	sut.remove_character(true)
	assert_eq(sut.get_active_character(), "")
	assert_false("fred" in sut.get_characters().keys())

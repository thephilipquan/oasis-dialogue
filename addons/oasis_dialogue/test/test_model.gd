extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const Model := preload("res://addons/oasis_dialogue/model/model.gd")

var sut: Model = null


func before_each() -> void:
	sut = Model.new()


func test_save_path() -> void:
	assert_eq(sut.get_save_path(), "")
	assert_false(sut.has_save_path())

	sut.set_save_path("foo")

	assert_eq(sut.get_save_path(), "foo")
	assert_true(sut.has_save_path())


func test_conditions() -> void:
	var conditions: Array[String] = [
		"has_gold",
		"is_day",
	]
	sut.set_conditions(conditions)
	assert_eq_deep(sut._conditions, conditions)
	assert_true(sut.has_condition("has_gold"))
	assert_false(sut.has_condition("is_night"))


func test_actions() -> void:
	var actions: Array[String] = [
		"foo",
		"bar",
	]
	sut.set_actions(actions)
	assert_eq_deep(sut._actions, actions)
	assert_true(sut.has_action("foo"))
	assert_false(sut.has_action("eee"))


func test_is_active() -> void:
	assert_false(sut.is_active())
	sut.add_character("foo")
	sut.switch_character("foo")
	assert_true(sut.is_active())


func test_add_character() -> void:
	sut.add_character("foo")
	assert_true("foo" in sut.get_characters().keys())
	assert_eq(sut.get_characters()["foo"].name, "foo")
	assert_eq(sut.get_characters()["foo"].branches.size(), 0)


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
	var annotations: Array[AST.Annotation] = [
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
	assert_eq(sut.get_characters()["bar"].name, "bar")


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


func test_to_json() -> void:
	sut.add_character("fred")
	sut.set_actions(["foo"])
	sut.set_conditions(["bar"])
	sut.set_save_path("to/somewhere")

	var got := sut.to_json()
	var expected := {
		"actions": [ "foo" ],
		"conditions": [ "bar" ],
		"save_path": "to/somewhere",
		"characters": [
			{
				"name": "fred",
				"branches": [],
			},
		],
	}
	assert_eq_deep(got, expected)


func test_from_json() -> void:
	var json := {
		"actions": [ "foo" ],
		"conditions": [ "bar" ],
		"save_path": "to/somewhere",
		"characters": [
			{
				"name": "fred",
				"branches": [],
			},
		],
	}
	sut.from_json(json)

	assert_true(sut.has_character("fred"))
	assert_eq_deep(sut.get_characters()["fred"].branches, {})
	assert_eq(sut.get_save_path(), json["save_path"])
	assert_eq(sut._conditions, json["conditions"])
	assert_eq(sut._actions, json["actions"])


func test_load_project() -> void:
	const test_path := "res://test_model_load.json"
	var file := FileAccess.open(test_path, FileAccess.WRITE)
	if not file:
		fail_test("")
		return
	var json := {
		"actions": [ "foo" ],
		"conditions": [ "bar" ],
		"save_path": "to/somewhere",
		"characters": [
			{
				"name": "fred",
				"branches": [],
			},
		],
	}
	file.store_string(JSON.stringify(json))
	file.close()

	sut.load_project(test_path)

	assert_true(sut.has_character("fred"))
	assert_eq_deep(sut.get_characters()["fred"].branches, {})
	assert_eq(sut.get_save_path(), json["save_path"])
	assert_eq(sut._conditions, json["conditions"])
	assert_eq(sut._actions, json["actions"])
	var dir := DirAccess.open(test_path.get_base_dir())
	dir.remove(test_path)


func test_save_project() -> void:
	const test_path := "res://test_save_project.json"
	sut.add_character("fred")
	sut.set_actions(["foo"])
	sut.set_conditions(["bar"])
	sut.set_save_path(test_path)

	sut.save_project()

	assert_true(FileAccess.file_exists(test_path))
	var dir := DirAccess.open(test_path.get_base_dir())
	dir.remove(test_path)

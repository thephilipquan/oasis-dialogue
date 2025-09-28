extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const Model := preload("res://addons/oasis_dialogue/model/model.gd")

var sut: Model = null


func before_each() -> void:
	sut = Model.new()


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


func test_get_active_character() -> void:
	sut._active = "fred"
	assert_eq(sut.get_active_character(), "fred")


func test_get_characters() -> void:
	sut._characters = [ "fred", "joe" ]
	assert_eq_deep(sut.get_characters(), [ "fred", "joe" ])


func test_get_branches() -> void:
	var branches: Dictionary[int, AST.Branch] = {
		0: AST.Branch.new(0, [], [], []),
		1: AST.Branch.new(1, [], [], []),
	}
	sut._branches = branches
	assert_eq_deep(sut.get_branches(), branches)


func test_load_character() -> void:
	var d := {
		"name": "fred",
		"branches": {
			0: {
				"id": 0,
				"annotations": [],
				"prompts": [],
				"responses": [],
			},
			1: {
				"id": 1,
				"annotations": [],
				"prompts": [],
				"responses": [],
			},
		},
	}

	sut.load_character(d)

	assert_eq(sut.get_active_character(), "fred")
	var got := sut.get_branches()
	assert_true(0 in got)
	assert_true(1 in got)


func test_load_character_emits_character_changed() -> void:
	var d := {
		"name": "fred",
	}
	watch_signals(sut)

	sut.load_character(d)

	assert_eq(sut.get_active_character(), "fred")
	assert_signal_emitted_with_parameters(sut.character_changed, ["fred"])


func test_load_character_with_invalid_ast() -> void:
	push_warning("todo")
	pass_test("todo")


func test_load_character_with_empty_branches() -> void:
	var d := {
		"name": "fred",
		"branches": {},
	}
	sut.load_character(d)
	assert_eq(sut.get_active_character(), "fred")
	assert_eq_deep(sut.get_branches(), {})


func test_load_project() -> void:
	var d := {
		"characters": [ "fred", "joe" ],
		"actions": [ "a", "b" ],
		"conditions": [ "c", "d" ],
	}
	sut.load_project(d)
	assert_eq_deep(sut._characters, ["fred", "joe"])
	assert_eq_deep(sut._actions, ["a", "b"])
	assert_eq_deep(sut._conditions, ["c", "d"])


func test_load_project_overwrites() -> void:
	var d := {
		"characters": [ "fred", "joe" ],
		"actions": [ "a", "b" ],
		"conditions": [ "c", "d" ],
	}
	sut.load_project(d)

	d = {
		"characters": [ "jim", "tom" ],
		"actions": [ "e" ],
		"conditions": [ "f" ],
	}
	sut.load_project(d)

	assert_eq_deep(sut._characters, [ "jim", "tom" ])
	assert_eq_deep(sut._actions, [ "e" ])
	assert_eq_deep(sut._conditions, [ "f" ])


func test_save_project() -> void:
	var before := {
		"characters": [ "fred", "joe" ],
		"actions": [ "a", "b" ],
		"conditions": [ "c", "d" ],
	}
	sut.load_project(before)
	var after := {}

	sut.save_project(after)

	assert_eq_deep(after, before)


func test_save_character_stores_branches() -> void:
	var setup := {
		"name": "Fred",
		"branches": {
			0: {
				"id": 0,
				"annotations": [],
				"prompts": [],
				"responses": [],
			},
			1: {
				"id": 1,
				"annotations": [],
				"prompts": [],
				"responses": [],
			},
		},
	}
	# Calling load_character because that's the entry point to setting the
	# active character.
	sut.load_character(setup)
	var save := {}

	sut.save_character(save)

	gut.p("todo update model to ignore _active")
	var expected := {
		"branches": {
			0: {
				"id": 0,
				"annotations": [],
				"prompts": [],
				"responses": [],
			},
			1: {
				"id": 1,
				"annotations": [],
				"prompts": [],
				"responses": [],
			},
		},
	}
	assert_eq_deep(save, expected)


func test_add_character() -> void:
	sut.add_character("foo")
	sut.add_character("bar")
	assert_true("foo" in sut.get_characters())
	assert_eq_deep(sut.get_characters(), ["foo", "bar"])


func test_rename_active_character() -> void:
	var d := {
		"characters": [ "fred", "joe" ],
		"name": "fred",
	}
	sut.load_project(d)
	sut.load_character(d)

	sut.rename_active_character("tim")

	assert_eq(sut.get_active_character(), "tim")
	assert_eq_deep(sut.get_characters(), [ "tim", "joe" ])


func test_add_branch_with_no_active_character() -> void:
	sut.add_branch(0)

	assert_eq(sut.get_branches().size(), 0)


func test_add_branch() -> void:
	var d := {
		"characters": [ "fred", "joe" ],
		"name": "fred",
	}
	sut.load_project(d)
	sut.load_character(d)

	sut.add_branch(0)

	assert_eq(sut.get_branches().size(), 1)


func test_update_branch() -> void:
	var d := {
		"characters": [ "fred", "joe" ],
		"name": "fred",
	}
	sut.load_project(d)
	sut.load_character(d)

	sut.add_branch(0)

	var annotations: Array[AST.Annotation] = [
		AST.Annotation.new("rng", null),
	]
	var ast := AST.Branch.new(0, annotations, [], [])

	sut.update_branch(ast)

	var got := sut.get_branches()
	if not got:
		fail_test("expected branches, got none")
	else:
		assert_eq(got[0], ast)


func test_has_branch_exists() -> void:
	var d := {
		"characters": [ "fred", "joe" ],
		"name": "fred",
	}
	sut.load_project(d)
	sut.load_character(d)

	sut.add_branch(3)

	assert_true(sut.has_branch(3))


func test_has_branch_not_exists() -> void:
	var d := {
		"characters": [ "fred", "joe" ],
		"name": "fred",
	}
	sut.load_project(d)
	sut.load_character(d)

	sut.add_branch(3)

	assert_false(sut.has_branch(2))


func test_remove_branch() -> void:
	var d := {
		"characters": [ "fred", "joe" ],
		"name": "fred",
	}
	sut.load_project(d)
	sut.load_character(d)

	sut.add_branch(3)
	sut.add_branch(8)
	sut.add_branch(13)

	sut.remove_branch(8)

	assert_false(sut.has_branch(8))


func test_get_branch() -> void:
	var d := {
		"characters": [ "fred", "joe" ],
		"name": "fred",
	}
	sut.load_project(d)
	sut.load_character(d)

	sut.add_branch(0)

	var ast := sut.get_branch(0)
	assert_ne(ast, null)


func test_get_branch_ids() -> void:
	var d := {
		"characters": [ "fred", "joe" ],
		"name": "fred",
	}
	sut.load_project(d)
	sut.load_character(d)

	sut.add_branch(1)
	sut.add_branch(4)

	assert_eq_deep(sut.get_branch_ids(), [ 1, 4 ])


func test_remove_character() -> void:
	var d := {
		"characters": [ "fred", "joe" ],
		"name": "fred",
	}
	sut.load_project(d)
	sut.load_character(d)
	sut.add_branch(0)

	sut.remove_active_character()

	assert_eq(sut.get_active_character(), "")
	assert_eq_deep(sut.get_branches().size(), 0)
	assert_true(not "fred" in sut.get_characters())

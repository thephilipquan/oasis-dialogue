extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")


class TestAST:
	extends GutTest


	func test_from_json_pass_non_dictionary_returns_null() -> void:
		var ast := AST.from_json("")

		assert_null(ast)


	func test_from_json_without_type_returns_recovery() -> void:
		var ast := AST.from_json({ })

		assert_is(ast, AST.Recovery)


	func test_from_json_unrecognized_type_returns_recovery() -> void:
		var ast := AST.from_json({ "type": "hello world" })

		assert_is(ast, AST.Recovery)


	func test_from_json_type_branch_returns_branch() -> void:
		var json := {
				"type": AST.TYPE_BRANCH,
		}
		var ast := AST.from_json(json)
		assert_is(ast, AST.Branch)


	func test_from_json_type_annotation_returns_annotation() -> void:
		var json := {
				"type": AST.TYPE_ANNOTATION,
				"name": "a",
		}
		var ast := AST.from_json(json)
		assert_is(ast, AST.Annotation)


	func test_from_json_type_prompt_returns_prompt() -> void:
		var json := {
				"type": AST.TYPE_PROMPT,
		}
		var ast := AST.from_json(json)
		assert_is(ast, AST.Prompt)


	func test_from_json_type_response_returns_response() -> void:
		var json := {
				"type": AST.TYPE_RESPONSE,
		}
		var ast := AST.from_json(json)
		assert_is(ast, AST.Response)


	func test_from_json_type_condition_returns_condition() -> void:
		var json := {
				"type": AST.TYPE_CONDITION,
				"name": "a",
		}
		var ast := AST.from_json(json)
		assert_is(ast, AST.Condition)


	func test_from_json_type_action_returns_action() -> void:
		var json := {
				"type": AST.TYPE_ACTION,
				"name": "a",
		}
		var ast := AST.from_json(json)
		assert_is(ast, AST.Action)


	func test_from_json_type_string_literal_returns_string_literal() -> void:
		var json := {
				"type": AST.TYPE_STRING_LITERAL,
				"value": "",
		}
		var ast := AST.from_json(json)
		assert_is(ast, AST.StringLiteral)


	func test_from_json_type_number_literal_returns_number_literal() -> void:
		var json := {
				"type": AST.TYPE_NUMBER_LITERAL,
				"value": 0,
		}
		var ast := AST.from_json(json)
		assert_is(ast, AST.NumberLiteral)


class TestLine:
	extends GutTest


	func test_add_appends_to_children() -> void:
		var ast := AST.Line.new()
		ast.add(AST.Leaf.new())

		assert_eq(ast.children.size(), 1)


	func test_to_json_sets_children() -> void:
		var ast := AST.Line.new()
		for i in 3:
			ast.add(AST.NumberLiteral.new(i))

		var json := ast.to_json()

		var children := json.get("children", [])
		assert_eq(children.size(), 3)

		for child in children:
			assert_not_null(child)


	func test_to_json_sets_line() -> void:
		var ast := AST.Line.new()
		ast.line = 2

		var json := ast.to_json()

		assert_eq(json.get("line", 0), 2)


	func test_from_json_returns_instance() -> void:
		var json := { }

		var ast := AST.Line.from_json(json) as AST.Line

		assert_is(ast, AST.Line)


	func test_from_json_restores_line() -> void:
		var json := {
				"line": 3
		}
		var ast := AST.Line.from_json(json) as AST.Line
		assert_eq(ast.line, 3)


	func test_from_json_restores_children() -> void:
		var json := {
				"children": [
					{
						"type": AST.TYPE_NUMBER_LITERAL,
						"value": 1,
					},
					{
						"type": AST.TYPE_NUMBER_LITERAL,
						"value": 2,
					},
					{
						"type": AST.TYPE_NUMBER_LITERAL,
						"value": 3,
					},
				]
		}

		var ast: AST.Line = AST.Line.from_json(json)

		assert_eq(ast.children.size(), 3)


	func test_from_json_with_instance_returns_same_instance() -> void:
		var line := AST.Line.new()
		var ast := AST.Line.from_json({ }, line)
		assert_same(ast, line)


	func test_from_json_with_invalid_instance_returns_new_instance() -> void:
		var leaf := AST.Leaf.new()
		var ast := AST.Line.from_json({ }, leaf)
		assert_not_same(ast, leaf)


class TestLeaf:
	extends GutTest


	func test_to_json_sets_line() -> void:
		var ast := AST.Leaf.new()
		ast.line = 3
		ast.column = 7

		var json := ast.to_json()

		assert_eq(json.get("line", -1), 3)


	func test_from_json_restores_line() -> void:
		var json := { "line": 20 }
		var ast := AST.Leaf.from_json(json) as AST.Leaf
		assert_eq(ast.line, 20)


	func test_from_json_with_instance_returns_same_instance() -> void:
		var leaf := AST.Leaf.new()
		var ast := AST.Leaf.from_json({ }, leaf)
		assert_same(ast, leaf)


	func test_from_json_with_invalid_instance_returns_new_instance() -> void:
		var line := AST.Line.new()
		var ast := AST.Leaf.from_json({ }, line)
		assert_not_same(ast, line)


class TestBranch:
	extends GutTest


	func test_to_json_sets_type() -> void:
		var ast := AST.Branch.new()
		var json := ast.to_json()
		assert_eq(json.get("type", ""), AST.TYPE_BRANCH)


	func test_from_json_returns_instance() -> void:
		var json := { "type": AST.TYPE_BRANCH }
		var ast := AST.Branch.from_json(json)
		assert_is(ast, AST.Branch)


	func test_from_json_restores_id() -> void:
		var json := { "id": 7 }
		var ast := AST.Branch.from_json(json) as AST.Branch
		assert_eq(ast.id, 7)


	func test_from_malformed_json_restores_id_as_negative_one() -> void:
		var json := { "id": "hey" }
		var ast := AST.Branch.from_json(json)
		assert_eq(ast.id, -1)


class TestPrompt:
	extends GutTest

	func test_to_json_sets_type() -> void:
		var sut := AST.Prompt.new()
		var json := sut.to_json()

		assert_eq(json.get("type", ""), AST.TYPE_PROMPT)


class TestAnnotation:
	extends GutTest


	func test_to_json_sets_type() -> void:
		var ast := AST.Annotation.new("")
		var json := ast.to_json()
		assert_eq(json.get("type", ""), AST.TYPE_ANNOTATION)


	func test_to_json_sets_name() -> void:
		var ast := AST.Annotation.new("foo")
		var json := ast.to_json()
		assert_eq(json.get("name", ""), "foo")


	func test_from_json_returns_instance() -> void:
		var ast := AST.Annotation.from_json({ "name": "a" })
		assert_is(ast, AST.Annotation)


	func test_from_json_restores_name() -> void:
		var json := { "name": "foo" }
		var ast := AST.Annotation.from_json(json) as AST.Annotation
		assert_eq(ast.name, "foo")


	func test_from_malformed_json_returns_recovery() -> void:
		var json := { "name": [] }
		var ast := AST.Annotation.from_json(json)
		assert_is(ast, AST.Recovery)


class TestCondition:
	extends GutTest


	func test_to_json_sets_type() -> void:
		var ast := AST.Condition.new("")
		var json := ast.to_json()
		assert_eq(json.get("type", ""), AST.TYPE_CONDITION)


	func test_to_json_sets_name() -> void:
		var ast := AST.Condition.new("foo")
		var json := ast.to_json()
		assert_eq(json.get("name", ""), "foo")


	func test_to_json_sets_line() -> void:
		var ast := AST.Condition.new("foo", null, 3, 7)
		var json := ast.to_json()
		assert_eq(json.get("line", 3), 3)


	func test_to_json_sets_value_if_exists() -> void:
		var ast := AST.Condition.new(
				"foo",
				AST.NumberLiteral.new(27),
				3,
				7,
		)
		var json := ast.to_json()
		assert_not_null(json.get("value"))


	func test_from_json_returns_instance() -> void:
		var ast := AST.Condition.from_json({ "name": "a" })
		assert_is(ast, AST.Condition)


	func test_from_json_restores_name() -> void:
		var json := { "name": "foo" }
		var ast := AST.Condition.from_json(json) as AST.Condition
		assert_eq(ast.name, "foo")


	func test_from_json_with_value_restores_value() -> void:
		var json := {
				"name": "foo",
				"value": {
					"type": AST.TYPE_NUMBER_LITERAL,
					"value": 3
				}
		}
		var ast := AST.Condition.from_json(json) as AST.Condition
		assert_not_null(ast.value)


	func test_from_malformed_json_returns_recovery() -> void:
		var json := { "name": 3}
		var ast := AST.Condition.from_json(json)
		assert_is(ast, AST.Recovery)


class TestAction:
	extends GutTest


	func test_to_json_sets_type() -> void:
		var ast := AST.Action.new("")
		var json := ast.to_json()
		assert_eq(json.get("type", ""), AST.TYPE_ACTION)


	func test_to_json_sets_name() -> void:
		var ast := AST.Action.new("foo")
		var json := ast.to_json()
		assert_eq(json.get("name", ""), "foo")


	func test_to_json_sets_if_exists() -> void:
		var ast := AST.Action.new("foo", AST.NumberLiteral.new(3))
		var json := ast.to_json()
		assert_true("value" in json)
		assert_not_null(json.get("value", null))


	func test_from_json_returns_instance() -> void:
		var ast := AST.Action.from_json({ "name": "a" })
		assert_is(ast, AST.Action)


	func test_from_json_restores_name() -> void:
		var json := { "name": "foo" }
		var ast := AST.Action.from_json(json) as AST.Action
		assert_eq(ast.name, "foo")


	func test_from_json_with_value_restores_value() -> void:
		var json := {
				"name": "foo",
				"value": {
					"type": AST.TYPE_NUMBER_LITERAL,
					"value": 3
				}
		}
		var ast := AST.Action.from_json(json) as AST.Action
		assert_not_null(ast.value)


	func test_from_malformed_json_returns_recovery() -> void:
		var json := { "name": 3}
		var ast := AST.Action.from_json(json)
		assert_is(ast, AST.Recovery)


	func test_test_equals_other_type_returns_false() -> void:
		var a := AST.Action.new("foo", AST.NumberLiteral.new(0))
		var b := AST.Condition.new("foo", AST.NumberLiteral.new(0))
		assert_false(a.equals(b))


	func test_test_equals_null_returns_false() -> void:
		var a := AST.Action.new("foo", AST.NumberLiteral.new(0))
		assert_false(a.equals(null))


	func test_test_equals_other_has_different_name_returns_false() -> void:
		var a := AST.Action.new("foo", AST.NumberLiteral.new(0))
		var b := AST.Action.new("bar", AST.NumberLiteral.new(0))
		assert_false(a.equals(b))


	func test_test_equals_value_is_null_and_other_value_is_not_null_returns_false() -> void:
		var a := AST.Action.new("foo")
		var b := AST.Condition.new("foo", AST.NumberLiteral.new(0))
		assert_false(a.equals(b))


	func test_test_equals_value_not_null_and_other_value_is_null_return_false() -> void:
		var a := AST.Action.new("foo", AST.NumberLiteral.new(0))
		var b := AST.Action.new("foo")
		assert_false(a.equals(b))


	func test_test_equals_both_values_null_returns_true() -> void:
		var a := AST.Action.new("foo")
		var b := AST.Action.new("foo")
		assert_true(a.equals(b))


	func test_test_equals_both_values_non_null_return_value_equals_result() -> void:
		var a := AST.Action.new("foo", AST.NumberLiteral.new(0))
		var b := AST.Action.new("foo", AST.NumberLiteral.new(0))
		assert_true(a.equals(b))


class TestStringLiteral:
	extends GutTest


	func test_to_json_sets_type() -> void:
		var ast := AST.StringLiteral.new("")
		var json := ast.to_json()
		assert_eq(json.get("type", ""), AST.TYPE_STRING_LITERAL)


	func test_to_json_sets_value() -> void:
		var ast := AST.StringLiteral.new("foo")
		var json := ast.to_json()
		assert_eq(json.get("value", ""), "foo")


	func test_from_json_returns_instance() -> void:
		var ast := AST.StringLiteral.from_json({ "value": "a" })
		assert_is(ast, AST.StringLiteral)


	func test_from_json_restores_value() -> void:
		var json := { "value": "foo" }
		var ast := AST.StringLiteral.from_json(json) as AST.StringLiteral
		assert_eq(ast.value, "foo")


	func test_from_malformed_json_returns_recovery() -> void:
		var json := { "value": 3 }
		var ast := AST.StringLiteral.from_json(json)
		assert_is(ast, AST.Recovery)


class TestNumberLiteral:
	extends GutTest


	func test_to_json_sets_type() -> void:
		var ast := AST.NumberLiteral.new(0)
		var json := ast.to_json()
		assert_eq(json.get("type", ""), AST.TYPE_NUMBER_LITERAL)


	func test_to_json_sets_value() -> void:
		var ast := AST.NumberLiteral.new(2)
		var json := ast.to_json()
		assert_eq(json.get("value", -1), 2)


	func test_from_json_returns_instance() -> void:
		var json := { "value": 3 }

		var ast := AST.NumberLiteral.from_json(json)

		assert_is(ast, AST.NumberLiteral)


	func test_from_json_restores_value() -> void:
		var json := {
				"type": AST.TYPE_NUMBER_LITERAL,
				"value": 3,
		}

		var ast: AST.NumberLiteral = AST.NumberLiteral.from_json(json)

		assert_eq(ast.value, 3)


	func test_from_json_restores_float_as_int() -> void:
		var json := {
				"type": AST.TYPE_NUMBER_LITERAL,
				"value": 3.0,
		}

		var ast: AST.NumberLiteral = AST.NumberLiteral.from_json(json)

		assert_eq(ast.value, 3)


	func test_from_malformed_json_returns_recovery() -> void:
		var json := { "value": "hey" }
		var ast := AST.NumberLiteral.from_json(json)
		assert_is(ast, AST.Recovery)


class TestRecovery:
	extends GutTest


	func test_init_message_is_set() -> void:
		var ast := AST.Recovery.new({
				"children": [
					{
						"value": 3,
					},
				]
		})

		assert_ne(ast.message, "")


	func test_init_line_is_set() -> void:
		var ast := AST.Recovery.new({
				"line": 6,
		})

		assert_eq(ast.line, 6)


	func test_init_line_is_defaulted_to_negative_one() -> void:
		var ast := AST.Recovery.new({ "value": "hello world" })

		assert_eq(ast.line, -1)

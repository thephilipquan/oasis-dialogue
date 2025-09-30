extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")


class TestBranch:
	extends GutTest

	var sut: AST.Branch = null


	func after_each() -> void:
		sut = null


	func test_from_json() -> void:
		sut = AST.Branch.from_json({
				"id": 1,
				"annotations": [
					{
						"name": "a",
					}
				],
				"prompts": [
					{
						"text": { "value": "a" },
					},
				],
				"responses": [
					{
						"text": { "value": "b" },
					},
				],
		})

		assert_eq(sut.id, 1)
		assert_eq(sut.annotations.size(), 1)
		assert_eq(sut.prompts.size(), 1)
		assert_eq(sut.responses.size(), 1)


	func test_from_json_defaults() -> void:
		sut = AST.Branch.from_json({ })

		assert_eq(sut.id, -1)
		assert_eq_deep(sut.annotations, [])
		assert_eq_deep(sut.prompts, [])
		assert_eq_deep(sut.responses, [])


	func test_from_jsons_with_invalid_key_skips_item() -> void:
		var branches := AST.Branch.from_jsons({
				1: {
					"prompts": [
						{
							"text": { "value": "a" },
						},
					],
				},
				"tom": {
					"responses": [
						{
							"text": { "value": "b" },
						},
					],
				},
		})

		assert_eq(branches.size(), 1)


	func test_from_jsons_with_invalid_value_skips_item() -> void:
		var branches := AST.Branch.from_jsons({
				1: {
					"prompts": [
						{
							"text": { "value": "a" },
						},
					],
				},
				2: "hey",
		})

		assert_eq(branches.size(), 1)


	func test_from_jsons_returns_empty_array_if_invalid_parameter() -> void:
		var branches := AST.Branch.from_jsons("hey")

		assert_eq(branches.size(), 0)


class TestAnnotation:
	extends GutTest

	var sut: AST.Annotation = null


	func after_each() -> void:
		sut = null


	func test_from_json() -> void:
		fail_test("")


	func test_from_json_with_invalid_name_value_returns_null() -> void:
		fail_test("")


	func test_from_json_without_name_returns_null() -> void:
		fail_test("")


	func test_from_json_defaults_line() -> void:
		fail_test("")


	func test_from_json_defaults_column() -> void:
		fail_test("")


	func test_from_jsons_ignores_invalid_items() -> void:
		fail_test("")


	func test_from_jsons_returns_empty_array_if_invalid_parameter() -> void:
		fail_test("")


class TestPrompt:
	extends GutTest

	var sut: AST.Prompt = null


	func after_each() -> void:
		sut = null


	func test_from_json() -> void:
		sut = AST.Prompt.from_json({
				"text": {
					"value": "hello world",
				},
		})

		assert_eq(sut.text.value, "hello world")


	func test_from_json_with_conditions() -> void:
		sut = AST.Prompt.from_json({
				"conditions":  [
					{
						"name": "is_day",
						"value": null,
					},
				],
				"text": {
					"value": "hello world",
				},
		})

		assert_eq(sut.conditions.size(), 1)


	func test_from_json_with_actions() -> void:
		sut = AST.Prompt.from_json({
				"text": {
					"value": "hello world",
				},
				"actions":  [
					{
						"name": "foo",
						"value": {
							"value": 3,
						}
					},
				],
		})

		assert_eq(sut.actions.size(), 1)


	func test_from_json_with_invalid_parameter() -> void:
		sut = AST.Prompt.from_json("hey")

		assert_eq(sut, null)


	func test_from_jsons_returns_empty_array_if_invalid_parameter() -> void:
		var responses := AST.Prompt.from_jsons("hey")

		assert_eq(responses.size(), 0)


class TestResponse:
	extends GutTest

	var sut: AST.Response = null


	func after_each() -> void:
		sut = null


	func test_from_json() -> void:
		sut = AST.Response.from_json({
				"text": {
					"value": "hello world",
				},
		})

		assert_eq(sut.text.value, "hello world")


	func test_from_json_with_conditions() -> void:
		sut = AST.Response.from_json({
				"conditions":  [
					{
						"name": "is_day",
						"value": null,
					},
				],
				"text": {
					"value": "hello world",
				},
		})

		assert_eq(sut.conditions.size(), 1)


	func test_from_json_with_actions() -> void:
		sut = AST.Response.from_json({
				"text": {
					"value": "hello world",
				},
				"actions":  [
					{
						"name": "foo",
						"value": {
							"value": 3,
						}
					},
				],
		})

		assert_eq(sut.actions.size(), 1)


	func test_from_json_with_invalid_parameter() -> void:
		sut = AST.Response.from_json("hey")

		assert_eq(sut, null)


	func test_from_jsons_ignores_invalid_items() -> void:
		var responses := AST.Response.from_jsons([
				{
					"text": "hey"
				},
				{
					"text": {
						"value": "hello world",
					},
				}
		])

		assert_eq(responses.size(), 1)
		assert_eq(responses[1].text.value, "hello world")


	func test_from_jsons_returns_empty_array_if_invalid_parameter() -> void:
		var responses := AST.Response.from_jsons("hey")

		assert_eq(responses.size(), 0)


class TestCondition:
	extends GutTest

	var sut: AST.Condition = null


	func after_each() -> void:
		sut = null


	func test_from_json_without_value() -> void:
		sut = AST.Condition.from_json({
				"name": "foo",
		})

		assert_eq(sut.name, "foo")
		assert_eq(sut.value, null)


	func test_from_json_with_value() -> void:
		sut = AST.Condition.from_json({
				"name": "foo",
				"value": {
					"value": 3,
				},
		})

		assert_eq(sut.name, "foo")
		assert_ne(sut.value, null)


	func test_from_json_with_invalid_parameter() -> void:
		fail_test("")


	func test_from_json_with_invalid_name() -> void:
		fail_test("")


	func test_from_jsons_ignore_invalid_items() -> void:
		fail_test("")


	func test_from_jsons_returns_empty_array_if_invalid_parameter() -> void:
		fail_test("")


class TestAction:
	extends GutTest

	var sut: AST.Action = null


	func after_each() -> void:
		sut = null


	func test_from_json_without_value() -> void:
		sut = AST.Action.from_json({
				"name": "foo",
		})

		assert_eq(sut.name, "foo")
		assert_eq(sut.value, null)


	func test_from_json_with_value() -> void:
		sut = AST.Action.from_json({
				"name": "foo",
				"value": {
					"value": 3,
				},
		})

		assert_eq(sut.name, "foo")
		assert_ne(sut.value, null)


	func test_from_json_with_invalid_parameter() -> void:
		fail_test("")


	func test_from_json_where_name_is_not_string() -> void:
		fail_test("")


	func test_from_jsons_ignore_invalid_items() -> void:
		fail_test("")


	func test_from_jsons_returns_empty_array_if_invalid_parameter() -> void:
		fail_test("")


class TestStringLiteral:
	extends GutTest

	var sut: AST.StringLiteral = null


	func after_each() -> void:
		sut = null


	func test_from_json() -> void:
		sut = AST.StringLiteral.from_json({
				"value": "foo",
		})

		assert_eq(sut.value, "foo")


	func test_from_json_without_value_returns_null() -> void:
		sut = AST.StringLiteral.from_json({ })

		assert_eq(sut, null)


	func test_from_json_with_different_type_returns_null() -> void:
		sut = AST.StringLiteral.from_json({
				"value": 3,
		})

		assert_eq(sut, null)


	func test_from_json_with_invalid_parameter() -> void:
		fail_test("")


	func test_to_json() -> void:
		sut = AST.StringLiteral.new("bar")

		var expected := {
			"value": "bar",
			"line": -1,
			"column": -1,
		}
		assert_eq(sut.to_json(), expected)


	func test_equals_same() -> void:
		sut = AST.StringLiteral.new("a")
		var other := AST.StringLiteral.new("a")

		assert_true(sut.equals(other))
		assert_true(other.equals(sut))


	func test_equals_not_same() -> void:
		sut = AST.StringLiteral.new("b")
		var other := AST.StringLiteral.new("c")

		assert_false(sut.equals(other))
		assert_false(other.equals(sut))


	func test_equals_null() -> void:
		sut = AST.StringLiteral.new("d")
		var other = null

		assert_false(sut.equals(other))


class TestNumberLiteral:
	extends GutTest

	var sut: AST.NumberLiteral = null


	func after_each() -> void:
		sut = null


	func test_from_json() -> void:
		sut = AST.NumberLiteral.from_json({
				"value": 3,
		})

		assert_eq(sut.value, 3)


	func test_from_json_with_float_value_is_valid() -> void:
		sut = AST.NumberLiteral.from_json({
				"value": 3.0,
		})

		assert_eq(sut.value, 3)


	func test_from_json_without_value_returns_null() -> void:
		sut = AST.NumberLiteral.from_json({ })

		assert_eq(sut, null)


	func test_from_json_with_different_type_returns_null() -> void:
		sut = AST.NumberLiteral.from_json({
				"value": "hey",
		})

		assert_eq(sut, null)


	func test_from_json_with_invalid_parameter() -> void:
		fail_test("")


	func test_to_json() -> void:
		sut = AST.NumberLiteral.new(2)

		var expected := {
			"value": 2,
			"line": -1,
			"column": -1,
		}
		assert_eq(sut.to_json(), expected)


	func test_equals_same() -> void:
		sut = AST.NumberLiteral.new(2)
		var other := AST.NumberLiteral.new(2)

		assert_true(sut.equals(other))
		assert_true(other.equals(sut))


	func test_equals_not_same() -> void:
		sut = AST.NumberLiteral.new(2)
		var other := AST.NumberLiteral.new(3)

		assert_false(sut.equals(other))
		assert_false(other.equals(sut))


	func test_equals_null() -> void:
		sut = AST.NumberLiteral.new(2)
		var other = null

		assert_false(sut.equals(other))

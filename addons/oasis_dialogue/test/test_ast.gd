extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")

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
		assert_eq(sut.text.value, "hello world")


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

		assert_eq(sut.text.value, "hello world")
		assert_eq(sut.actions.size(), 1)


class TestCondition:
	extends GutTest

	var sut: AST.Condition = null


	func after_each() -> void:
		sut = null


	func test_from_json() -> void:
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


class TestAction:
	extends GutTest

	var sut: AST.Action = null


	func after_each() -> void:
		sut = null


	func test_from_json() -> void:
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


	func test_from_json_with_malformed_data() -> void:
		sut = AST.StringLiteral.from_json({
				"value": 3,
		})

		assert_eq(sut, null)


	func test_to_json() -> void:
		sut = AST.StringLiteral.new("bar")

		assert_eq(sut.to_json(), { "value": "bar" })


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


	func test_from_json_float() -> void:
		sut = AST.NumberLiteral.from_json({
				"value": 3.0,
		})

		assert_eq(sut.value, 3)


	func test_from_json_with_malformed_data() -> void:
		sut = AST.NumberLiteral.from_json({
				"value": "hey",
		})

		assert_eq(sut, null)


	func test_to_json() -> void:
		sut = AST.NumberLiteral.new(2)

		assert_eq(sut.to_json(), { "value": 2 })


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

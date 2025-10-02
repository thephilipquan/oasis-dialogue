extends GutTest

const JsonUtils := preload("res://addons/oasis_dialogue/utils/json_utils.gd")

var sut := JsonUtils


func test_is_int_with_int_return_true() -> void:
	assert_true(sut.is_int(3))


func test_is_int_with_float_returns_false() -> void:
	assert_true(sut.is_int(3.0))


func test_is_int_with_string_value_return_true() -> void:
	assert_true(sut.is_int("3"))


func test_is_int_with_non_number_string_return_false() -> void:
	assert_false(sut.is_int("hey"))


func test_parse_int_pass_int() -> void:
	assert_eq(sut.parse_int(3), 3)


func test_parse_int_pass_float() -> void:
	assert_eq(sut.parse_int(3.2), 3)


func test_parse_int_pass_string_int() -> void:
	assert_eq(sut.parse_int("3"), 3)


func test_parse_int_pass_string_float_returns_int() -> void:
	assert_eq(sut.parse_int("3.6"), 3)


func test_get_vector2_value_is_not_dictionary_return_default() -> void:
	var got := sut.get_vector2(
			{
				"foo": "hey",
			},
			"foo",
			Vector2(1, 2),
	)
	assert_eq(got, Vector2(1, 2))


func test_get_vector2_pass_non_number_values_returns_default_x() -> void:
	var got := sut.get_vector2(
			{
				"x": "hey",
				"y": [],
			},
			"foo",
			Vector2(1, 2),
	)
	assert_eq(got, Vector2(1, 2))


func test_vector2_to_json() -> void:
	assert_eq(
			sut.vector2_to_json(Vector2(3, 4)),
			{ "x": 3, "y": 4 }
	)


func test_vector2_to_json_with_float_vector_converts_to_int() -> void:
	assert_eq(
			sut.vector2_to_json(Vector2(3.3333332, 4.77793)),
			{ "x": 3, "y": 5 }
	)


func test_safe_get() -> void:
	var got = sut.safe_get(
			{
				"foo": "hey",
			},
			"foo",
			"default",
	)
	var expected := "hey"
	assert_eq(got, expected)


func test_safe_get_value_is_different_from_default_returns_default() -> void:
	var got = sut.safe_get(
			{
				"foo": 3,
			},
			"foo",
			"default",
	)
	var expected := "default"
	assert_eq(got, expected)


func test_safe_get_inner_type_is_different_still_return_value() -> void:
	var got = sut.safe_get(
			{
				"foo": [1],
			},
			"foo",
			["a"],
	)
	var expected := [1]
	assert_eq_deep(got, expected)


func test_typeof_is_same() -> void:
	var json := { "key": 3 }
	var got := sut.is_typeof(json, "key", TYPE_INT)
	assert_true(got)


func test_typeof_is_not_same() -> void:
	var json := { "key": 3 }
	var got := sut.is_typeof(json, "key", TYPE_STRING)
	assert_false(got)

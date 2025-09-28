extends GutTest

const Vector2Utils := preload("res://addons/oasis_dialogue/utils/vector2_utils.gd")

var sut := Vector2Utils


func test_from_json() -> void:
	var got := sut.from_json({
		"x": 28,
		"y": 32.0,
	})

	assert_eq(got, Vector2(28, 32))


func test_from_json_defaults_to_zero() -> void:
	var got := sut.from_json({ })

	assert_eq(got, Vector2(0, 0))


func test_from_malformed_json_defaults_to_zero() -> void:
	var got := sut.from_json({
		"x": "hey",
		"y": [ 7 ],
	})

	assert_eq(got, Vector2(0, 0))


func test_to_json() -> void:
	var got := sut.to_json(Vector2(7, 23))
	var expected := {
		"x": 7,
		"y": 23,
	}
	assert_eq(got, expected)


func test_to_json_converts_to_int() -> void:
	var got := sut.to_json(Vector2(3.33377, -55.9))
	var expected := {
		"x": 3,
		"y": -56,
	}
	assert_eq(got, expected)

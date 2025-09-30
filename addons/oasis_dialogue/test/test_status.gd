extends GutTest

const Status := preload("res://addons/oasis_dialogue/canvas/status.gd")

# Too short of a value will render the timer inconsistant.
const TEST_DURATION := 0.5
const INVALID_COLOR := Color.RED

var sut: Status = null
var timer: Timer = null


func before_each() -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = TEST_DURATION

	sut = Status.new()
	sut._invalid_color = INVALID_COLOR
	sut._timer = timer
	sut.add_child(timer)

	add_child_autofree(sut)


func test_info_displays_message() -> void:
	sut.info("hello world")

	assert_eq(sut.text, "hello world")


func test_info_sets_text_empty_after_timeout() -> void:
	sut.info("hello world")

	await wait_for_signal(timer.timeout, TEST_DURATION)
	assert_eq(sut.text, "")


func test_info_restarts_timer() -> void:
	sut.info("hello world")

	await wait_seconds(TEST_DURATION / 2)
	sut.info("hello again")

	await wait_seconds(TEST_DURATION / 2)
	assert_eq(sut.text, "hello again")

	await wait_for_signal(timer.timeout, TEST_DURATION / 2)
	assert_eq(sut.text, "")


func test_info_removes_color_override() -> void:
	sut.add_theme_color_override("font_color", Color.BLUE)

	sut.info("hello world")

	assert_false(sut.has_theme_color_override("font_color"))


func test_err_sets_text() -> void:
	sut.err("hello world")

	assert_eq(sut.text, "hello world")


func test_err_sets_color_override() -> void:
	sut.err("hello world")

	assert_eq(sut.get_theme_color("font_color"), sut._invalid_color)


func test_err_stops_timer() -> void:
	sut.info("hello world")
	sut.err("err world")

	assert_true(timer.is_stopped())

extends GutTest

const InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.gd")
const InputDialogScene := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.tscn")

var sut: InputDialog = null


func before_each() -> void:
	sut = add_child_autofree(InputDialogScene.instantiate())


func test_line_edit_is_focused_on_ready() -> void:
	assert_true(sut._line_edit.has_focus())


func test_set_placeholder_text() -> void:
	sut.set_placeholder_text("foo")

	assert_eq(sut._line_edit.placeholder_text, "foo")


func test_set_validation() -> void:
	var validation := func(): pass

	sut.set_validation(validation)

	assert_eq(sut._validate, validation)


func test_on_invalid_change_status_is_visible() -> void:
	sut.set_validation(func(s: String): return "blah")

	sut._on_line_edit_text_submitted("")

	var status: Label = sut.find_child("Status")
	assert_true(sut.visible)


func test_on_change_illegal_characters_are_removed() -> void:
	sut.set_validation(func(s: String): return "")

	sut._on_line_edit_text_changed("  foo   " + sut.ILLEGAL_CHARS + "_bar")

	assert_eq(sut._line_edit.text, "foo_bar")


func test_on_valid_change_status_is_hidden() -> void:
	sut.set_validation(func(s: String): return "")

	sut._on_line_edit_text_changed("")

	var status: Label = sut.find_child("Status")
	if not status:
		fail_test("")
		return
	assert_false(status.visible)


func test_on_confirm_confirmed_emitted() -> void:
	sut.set_validation(func(s: String): return "")
	watch_signals(sut)

	sut._on_confirm_button_up()

	assert_signal_emit_count(sut.confirmed, 1)
	assert_signal_emitted(sut, "confirmed", ["foo"])


func test_on_confirm_but_not_valid_confirmed_not_emitted() -> void:
	sut.set_validation(func(s: String): return "foo")
	watch_signals(sut)

	sut._on_confirm_button_up()

	assert_signal_not_emitted(sut.confirmed)


func test_on_cancel_canceled_emitted() -> void:
	sut.set_validation(func(s: String): return "")
	watch_signals(sut)

	sut._on_cancel_button_up()

	assert_signal_not_emitted(sut.confirmed)

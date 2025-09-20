extends GutTest

const Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const BranchScene := preload("res://addons/oasis_dialogue/branch/branch.tscn")

var sut: Branch = null


func before_each() -> void:
	sut = BranchScene.instantiate()
	add_child_autofree(sut)


func test_init() -> void:
	var highlighter := SyntaxHighlighter.new()
	sut.init(highlighter)
	assert_eq(sut._code_edit.syntax_highlighter, highlighter)


func test_button_calls_on_remove() -> void:
	var on_remove := func(): pass_test("")
	sut.set_on_remove(on_remove)

	sut._on_remove_branch_button_up()


func test_set_id() -> void:
	sut.set_id(3)
	assert_eq(sut._id, 3)

	assert_eq(sut._id, 3)
	assert_eq(sut.title, "3")


func test_highlighting_non_empty_sets_erred() -> void:
	sut.highlight([1])

	assert_true(sut.is_erred())


func test_highlighting_empty_sets_erred_false() -> void:
	sut.highlight([])

	assert_false(sut.is_erred())


func test_set_text() -> void:
	sut.set_text("foo")
	assert_eq(sut._code_edit.text, "foo")


func test_color_normal() -> void:
	sut.color_normal()
	assert_eq(sut.get_theme_stylebox("titlebar"), sut._normal_style)


func test_color_invalid() -> void:
	sut.color_invalid()
	assert_eq(sut.get_theme_stylebox("titlebar"), sut._invalid_style)


func test_highlight() -> void:
	sut.set_text("""0
1
2
3
4
""")
	var errors: Array[int] = [1, 3, 4]
	sut.highlight(errors)

	var _code_edit := sut._code_edit
	for i in 5:
		var color := Color.TRANSPARENT
		if i in errors:
			assert_ne(_code_edit.get_line_background_color(i), color)
		else:
			assert_eq(_code_edit.get_line_background_color(i), color)


func test_highlight_empty_errors() -> void:
	sut.set_text("""0
1
2
3
4
""")

	sut.highlight([])

	var _code_edit := sut._code_edit
	for i in 5:
		assert_eq(_code_edit.get_line_background_color(i), Color.TRANSPARENT)


func test_change_emits_changed_after_period() -> void:
	watch_signals(sut)
	sut.set_id(4)
	sut._code_edit.text = "foo"

	# Simulate text changing.
	sut._code_edit.text_changed.emit()

	await wait_for_signal(sut.changed, 2)
	assert_signal_emitted_with_parameters(sut.changed, [4, "foo"])


func test_show_button_on_node_select() -> void:
	sut._on_node_selected()

	var button := sut.find_child("*Button*", true, false)
	assert_true(button.visible)


func test_hide_button_on_node_deselect() -> void:
	sut._on_node_selected()

	sut._on_node_deselected()

	var button := sut.find_child("*Button*", true, false)
	assert_false(button.visible)

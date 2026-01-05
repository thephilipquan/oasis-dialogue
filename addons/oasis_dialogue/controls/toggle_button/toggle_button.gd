@tool
extends PanelContainer

signal left_selected
signal right_selected

@export
var _left_text := "":
	set(value):
		_left_text = value

		if not is_node_ready():
			return

		_left.text = _left_text
		_resize()

@export
var _right_text := "":
	set(value):
		_right_text = value

		if not is_node_ready():
			return

		_right.text = _right_text
		_resize()

@export
var selected := false:
	set(value):
		selected = value

		if not is_node_ready():
			return

		_style_boxes()
		_color_font()

@export_group("Style")
@export
var selected_style: StyleBox = null
@export
var unselected_style: StyleBox = null
@export
var selected_font_color := Color()
@export
var unselected_font_color := Color()


@onready
var _left: Label = $HBoxContainer/Left
@onready
var _right: Label = $HBoxContainer/Right


func _ready() -> void:
	# Setters are set before children are instantiated and able to be referenced.
	# Hence, the is_node_ready check in them. Here we set them after everything
	# is ready.
	_left.text = _left_text
	_right.text = _right_text
	_resize()
	selected = selected


func _style_boxes() -> void:
	const INSIDE_PADDING := 8
	const OUTSIDE_PADDING := 16

	var unselected_label: Label = null
	var selected_label: Label = null
	var left_padding := -1
	var right_padding := -1
	if not selected:
		selected_label = _left
		unselected_label = _right
		left_padding = INSIDE_PADDING
		right_padding = OUTSIDE_PADDING
	else:
		unselected_label = _left
		selected_label = _right
		left_padding = OUTSIDE_PADDING
		right_padding = INSIDE_PADDING

	unselected_style.content_margin_left = left_padding
	unselected_style.content_margin_right = right_padding
	unselected_label.add_theme_stylebox_override(&"normal", unselected_style)
	selected_label.add_theme_stylebox_override(&"normal", selected_style)


func _color_font() -> void:
	var unselected_label: Label = null
	var selected_label: Label = null
	if not selected:
		selected_label = _left
		unselected_label = _right
	else:
		unselected_label = _left
		selected_label = _right

	unselected_label.add_theme_color_override(&"font_color", unselected_font_color)
	selected_label.add_theme_color_override(&"font_color", selected_font_color)


func _on_left_gui_input(event: InputEvent) -> void:
	_on_press(event, false)


func _on_right_gui_input(event: InputEvent) -> void:
	_on_press(event, true)


func _on_press(event: InputEvent, side: bool) -> void:
	var cast := event as InputEventMouseButton
	if (
		not cast
		or not cast.pressed
		or selected == side
	):
		return

	selected = side
	if not selected:
		left_selected.emit()
	else:
		right_selected.emit()


func _resize() -> void:
	size = get_minimum_size()

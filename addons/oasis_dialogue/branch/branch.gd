@tool
extends GraphNode

const _HoverableToggleButton = preload("res://addons/oasis_dialogue/controls/hoverable_toggle_button.gd")

signal changed(id: int, text: String)
signal removed(id: int)
signal lock_changed()

@export
var _invalid_style: StyleBox = null

@onready
var _code_edit: CodeEdit = $CodeEdit
@onready
var _lock: TextureButton = $Lock
@onready
var _remove: TextureButton = $Remove

var _id := -1
var _is_erred := false

func _ready() -> void:
	if is_part_of_edited_scene():
		return

	var hbox := get_titlebar_hbox()
	hbox.add_spacer(false)
	_lock.reparent(hbox)
	_remove.reparent(hbox)

	node_selected.connect(_on_node_selected)
	node_deselected.connect(_on_node_deselected)


func init(highlighter: SyntaxHighlighter) -> void:
	($CodeEdit as CodeEdit).syntax_highlighter = highlighter


func is_erred() -> bool:
	return _is_erred


func is_locked() -> bool:
	return _lock.button_pressed


func set_locked(value: bool, silent := false) -> void:
	if silent:
		_lock.set_pressed_no_signal(value)
	else:
		_lock.button_pressed = value
		lock_changed.emit()


func set_id(id: int) -> void:
	_id = id
	title = str(_id)


func set_text(text: String) -> void:
	_code_edit.text = text


func get_text() -> String:
	return _code_edit.text


func highlight(line_errors: Array[int]) -> void:
	_is_erred = line_errors.size() > 0

	for i in _code_edit.get_line_count():
		var color := Color.TRANSPARENT
		if i in line_errors:
			color = Color.PALE_VIOLET_RED
		_code_edit.set_line_background_color(i, color)


func color_invalid() -> void:
	add_theme_stylebox_override("titlebar", _invalid_style)
	add_theme_stylebox_override("titlebar_selected", _invalid_style)


func color_normal() -> void:
	if has_theme_stylebox_override("titlebar"):
		remove_theme_stylebox_override("titlebar")
	if has_theme_stylebox_override("titlebar_selected"):
		remove_theme_stylebox_override("titlebar_selected")


func emit_removed() -> void:
	removed.emit(_id)


func _on_code_edit_text_changed() -> void:
	var parser_timer: Timer = $ParserTimer
	parser_timer.start()
	reset_size()


func _on_parser_timer_timeout() -> void:
	changed.emit(_id, _code_edit.text)


func _on_node_selected() -> void:
	_lock.show()
	_remove.show()


func _on_node_deselected() -> void:
	_lock.hide()
	_remove.hide()

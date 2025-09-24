@tool
extends GraphNode

signal changed(id: int, text: String)
signal removed(id: int, node: GraphNode)

@export
var _invalid_style: StyleBox = null

@onready
var _code_edit: CodeEdit = $CodeEdit

var _id := -1
var _remove_button: Button = null

var _is_erred := false


func _ready() -> void:
	var hbox := get_titlebar_hbox()
	hbox.add_spacer(false)

	_remove_button = Button.new()
	_remove_button.visible = false
	_remove_button.text = "remove"
	_remove_button.button_up.connect(_on_remove_branch_button_up)
	hbox.add_child(_remove_button)


func init(highlighter: SyntaxHighlighter) -> void:
	($CodeEdit as CodeEdit).syntax_highlighter = highlighter


func is_erred() -> bool:
	return _is_erred


func set_id(id: int) -> void:
	_id = id
	title = str(_id)


func set_text(text: String) -> void:
	_code_edit.text = text


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


func _on_code_edit_text_changed() -> void:
	var parser_timer: Timer = $ParserTimer
	parser_timer.start()


func _on_parser_timer_timeout() -> void:
	changed.emit(_id, _code_edit.text)


func _on_remove_branch_button_up() -> void:
	removed.emit(_id, self)


func _on_node_selected() -> void:
	_remove_button.visible = true


func _on_node_deselected() -> void:
	_remove_button.visible = false

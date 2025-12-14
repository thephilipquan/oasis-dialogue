@tool
extends TextEdit

const _Highlighter := preload("res://addons/oasis_dialogue/definition_panel/highlighter.gd")
const _Shared := preload("res://addons/oasis_dialogue/definition_panel/shared.gd")

@export
var _shared: _Shared = null


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	const theme_type := "DefinitionTextEdit"
	var highlighter := _Highlighter.new()
	highlighter.lexer = _shared.lexer
	highlighter.annotation_color = get_theme_color("annotation_color", theme_type)
	highlighter.identifier_color = get_theme_color("identifier_color", theme_type)
	highlighter.description_color = get_theme_color("description_color", theme_type)

	syntax_highlighter = highlighter


func clear_highlights() -> void:
	for i in get_line_count():
		set_line_background_color(i, Color.TRANSPARENT)


func highlight(line: int) -> void:
	var color := get_theme_color("invalid_color", "Project")
	color.a = 0.5
	set_line_background_color(line, color)

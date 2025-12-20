@tool
extends Control

@export
var _parent_split_container: HSplitContainer = null
@export
var _panel: Control = null
@export
var settings_header := ""

var _separation_offset := 0


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	_panel.visibility_changed.connect(update_size, CONNECT_DEFERRED)
	_parent_split_container.dragged.connect(update_size.unbind(1))
	_separation_offset = get_theme_constant("separation", "SplitContainer")


func update_size() -> void:
	var width := 0
	if _panel.visible:
		width = absi(_parent_split_container.split_offset) + _separation_offset
	custom_minimum_size.x = width

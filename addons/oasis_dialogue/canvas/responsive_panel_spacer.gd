@tool
extends Control

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")

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

	_panel.visibility_changed.connect(update_size)
	_parent_split_container.dragged.connect(update_size.unbind(1))
	_separation_offset = get_theme_constant("separation", "SplitContainer")


func setup(registry: _Registry) -> void:
	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	manager.settings_loaded.connect(load_settings)


func update_size() -> void:
	var width := 0
	if _panel.visible:
		width = _panel.size.x + _separation_offset
	custom_minimum_size.x = width


func load_settings(file: ConfigFile) -> void:
	var visible: bool = file.get_value(settings_header, "visible", false)
	var width: int = absi(file.get_value(settings_header, "width", 0)) + _separation_offset
	if visible:
		set_deferred("custom_minimum_size", Vector2(width, 0))

@tool
extends TextureButton

const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

@export
var settings_header := ""


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	pressed.connect(flip)


func setup(registry: _Registry) -> void:
	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	manager.settings_loaded.connect(load_settings)


func load_settings(file: ConfigFile) -> void:
	var panel_is_visible: bool = file.get_value(settings_header, "visible", false)
	if panel_is_visible:
		flip()


func flip() -> void:
	flip_h = not flip_h

@tool
extends Node

const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

@export
var button: BaseButton = null
@export
var target: CanvasItem = null
@export
var container: SplitContainer = null
@export
var settings_header := ""


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	button.pressed.connect(toggle_visibility)


func toggle_visibility() -> void:
	target.visible = not target.visible


func setup(registry: _Registry) -> void:
	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	manager.saving_settings.connect(save_settings)
	manager.settings_loaded.connect(load_settings)


func save_settings(file: ConfigFile) -> void:
	file.set_value(settings_header, "visible", target.visible)
	file.set_value(settings_header, "width", container.split_offset)


func load_settings(file: ConfigFile) -> void:
	target.visible = file.get_value(settings_header, "visible", false)
	container.split_offset = file.get_value(settings_header, "width", 0)

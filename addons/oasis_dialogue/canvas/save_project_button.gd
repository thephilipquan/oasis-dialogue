@tool
extends Button

const REGISTRY_KEY := "save_project_button"

const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	button_up.connect(manager.save_project)

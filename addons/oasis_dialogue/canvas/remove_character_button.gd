@tool
extends TextureButton

const REGISTRY_KEY := "remove_character_button"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Handler := preload("res://addons/oasis_dialogue/canvas/remove_character_handler.gd")


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	manager.character_loaded.connect(show.unbind(1))

	var handler: _Handler = registry.at(_Handler.REGISTRY_KEY)
	handler.character_removed.connect(hide)

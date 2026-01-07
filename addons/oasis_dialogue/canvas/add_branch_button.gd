@tool
extends TextureButton

const REGISTRY_KEY := "add_branch_button"

const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _RemoveCharacterHandler := preload("res://addons/oasis_dialogue/canvas/remove_character_handler.gd")

signal branch_added(id: int)


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	manager.character_loaded.connect(show.unbind(1))

	var remove_character: _RemoveCharacterHandler = registry.at(_RemoveCharacterHandler.REGISTRY_KEY)
	remove_character.character_removed.connect(hide)


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	button_up.connect(_on_button_up)


func _on_button_up() -> void:
	branch_added.emit()

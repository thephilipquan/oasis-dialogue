@tool
extends TextureButton

const REGISTRY_KEY := "add_character_button"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)

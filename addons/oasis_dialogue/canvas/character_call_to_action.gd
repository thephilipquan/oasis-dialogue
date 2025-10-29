@tool
extends CenterContainer

const REGISTRY_KEY := "character_call_to_action"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)

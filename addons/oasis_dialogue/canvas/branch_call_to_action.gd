@tool
extends CenterContainer

const REGISTRY_KEY := "branch_call_to_action"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)

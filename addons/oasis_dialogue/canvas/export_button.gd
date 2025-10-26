extends Button

const REGISTRY_KEY := "export_button"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


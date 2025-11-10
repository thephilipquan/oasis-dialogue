@tool
extends Control

const REGISTRY_KEY := "project_dialog"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _OpenProject := preload("res://addons/oasis_dialogue/project_dialog/open_project.gd")

signal path_requested(path: String)


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var open_project: _OpenProject = registry.at(_OpenProject.REGISTRY_KEY)
	open_project.path_requested.connect(path_requested.emit)

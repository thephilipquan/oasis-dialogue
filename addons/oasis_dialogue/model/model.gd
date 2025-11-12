@tool
extends Node

const REGISTRY_KEY := "model"

const _OasisFile := preload("res://addons/oasis_dialogue/io/oasis_file.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _Save := preload("res://addons/oasis_dialogue/save.gd")

var _conditions: Array[String] = []
var _actions: Array[String] = []


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	manager.saving_conditions.connect(save_conditions)
	manager.conditions_loaded.connect(load_conditions)
	manager.saving_actions.connect(save_actions)
	manager.actions_loaded.connect(load_actions)


func set_conditions(conditions: Array[String]) -> void:
	_conditions = conditions


func has_condition(condition: String) -> bool:
	return condition in _conditions


func set_actions(actions: Array[String]) -> void:
	_actions = actions


func has_action(action: String) -> bool:
	return action in _actions


func save_conditions(file: _OasisFile) -> void:
	file.set_value(_Save.Project.CONDITIONS, _Save.DUMMY, "\n".join(_conditions))


func load_conditions(file: _OasisFile) -> void:
	var text: String = file.get_value(_Save.Project.CONDITIONS, _Save.DUMMY, "")
	set_conditions(text.split("\n"))


func save_actions(file: _OasisFile) -> void:
	file.set_value(_Save.Project.ACTIONS, _Save.DUMMY, "\n".join(_actions))


func load_actions(file: _OasisFile) -> void:
	var text: String = file.get_value(_Save.Project.ACTIONS, _Save.DUMMY, "")
	set_actions(text.split("\n"))

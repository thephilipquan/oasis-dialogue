@tool
extends Node

const REGISTRY_KEY := "model"

const _AddBranchButton := preload("res://addons/oasis_dialogue/canvas/add_branch_button.gd")
const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _BranchEdit := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _Global := preload("res://addons/oasis_dialogue/global.gd")
const _JsonUtils := preload("res://addons/oasis_dialogue/utils/json_utils.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _RemoveCharacterButton := preload("res://addons/oasis_dialogue/canvas/remove_character_button.gd")
const _Visitor := preload("res://addons/oasis_dialogue/visitor/visitor.gd")

var _conditions: Array[String] = []
var _actions: Array[String] = []
var _branches: Dictionary[int, _AST.Branch] = {}


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var add_branch_button: _AddBranchButton = (
			registry.at(_AddBranchButton.REGISTRY_KEY)
	)
	add_branch_button.branch_added.connect(add_branch)

	var remove_character_button: _RemoveCharacterButton = (
			registry.at(_RemoveCharacterButton.REGISTRY_KEY)
	)
	remove_character_button.character_removed.connect(clear_branches)

	var graph: _BranchEdit = registry.at(_BranchEdit.REGISTRY_KEY)
	graph.branch_removed.connect(remove_branch)

	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	manager.file_loaded.connect(load_character)
	manager.project_loaded.connect(load_project)
	manager.saving_file.connect(save_character)
	manager.saving_project.connect(save_project)


func set_conditions(conditions: Array[String]) -> void:
	_conditions = conditions


func has_condition(condition: String) -> bool:
	return condition in _conditions


func set_actions(actions: Array[String]) -> void:
	_actions = actions


func has_action(action: String) -> bool:
	return action in _actions


func add_branch(id: int) -> void:
	var branch := _AST.Branch.new()
	branch.id = id
	_branches[id] = branch


func update_branch(ast: _AST.Branch) -> void:
	assert(ast.id in _branches)
	_branches[ast.id] = ast


func get_branch(id: int) -> _AST.Branch:
	assert(has_branch(id))
	return _branches[id]


func get_branch_ids() -> Array[int]:
	return _branches.keys()


func remove_branch(id: int) -> void:
	_branches.erase(id)


func clear_branches() -> void:
	_branches.clear()


func has_branch(id: int) -> bool:
	return id in _branches


func get_branch_count() -> int:
	return _branches.size()


## Returns the branches of the [member _active] character.
func get_branches() -> Dictionary[int, _AST.Branch]:
	return _branches.duplicate()


func load_character(data: Dictionary) -> void:
	_branches.clear()

	var branches: Dictionary = _JsonUtils.safe_get(data, _Global.FILE_BRANCHES, {})
	for key in branches:
		var branch := _AST.from_json(branches[key])
		_branches[branch.id] = branch


func load_project(data: Dictionary) -> void:
	_conditions.clear()
	var conditions := _JsonUtils.safe_get(data, _Global.PROJECT_CONDITIONS, []) as Array
	for c in conditions:
		if c is String:
			_conditions.push_back(c)

	_actions.clear()
	var actions := _JsonUtils.safe_get(data, _Global.PROJECT_ACTIONS, []) as Array
	for c in actions:
		if c is String:
			_actions.push_back(c)


func save_project(data: Dictionary) -> void:
	data[_Global.PROJECT_CONDITIONS] = _conditions
	data[_Global.PROJECT_ACTIONS] = _actions


func save_character(save: Dictionary) -> void:
	var branches := {}
	for id in _branches:
		branches[id] = _branches[id].to_json()
	save[_Global.FILE_BRANCHES] = branches

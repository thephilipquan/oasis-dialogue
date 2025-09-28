extends RefCounted

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Global := preload("res://addons/oasis_dialogue/global.gd")
const _Visitor := preload("res://addons/oasis_dialogue/visitor/visitor.gd")

signal character_changed(name: String)

var _characters: Array[String] = []
var _conditions: Array[String] = []
var _actions: Array[String] = []

var _active := ""
var _branches: Dictionary[int, _AST.Branch] = {}


func get_active_character() -> String:
	return _active


func get_character_count() -> int:
	return _characters.size()


func get_characters() -> Array[String]:
	return _characters.duplicate()


func set_conditions(conditions: Array[String]) -> void:
	_conditions = conditions


func has_condition(condition: String) -> bool:
	return condition in _conditions


func set_actions(actions: Array[String]) -> void:
	_actions = actions


func has_action(action: String) -> bool:
	return action in _actions


func add_branch(id: int) -> void:
	if not _active:
		return
	_branches[id] = _AST.Branch.new(id, [], [], [])


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


func is_active() -> bool:
	return _active != ""


func has_character(name: String) -> bool:
	return name in _characters


func add_character(name: String) -> void:
	assert(not name in _characters)
	_characters.push_back(name)


func remove_active_character() -> void:
	_characters.erase(_active)
	_branches.clear()
	_active = ""


func rename_active_character(to: String) -> void:
	assert(_active and not to in _characters)
	_characters[_characters.find(_active)] = to
	_active = to


func has_branch(id: int) -> bool:
	return id in _branches


func get_branch_count() -> int:
	return _branches.size()


## Returns the branches of the [member _active] character.
func get_branches() -> Dictionary[int, _AST.Branch]:
	return _branches.duplicate()


func load_character(data: Dictionary) -> void:
	_active = data.get(_Global.SAVE_FILE_NAME, "")
	_branches = _AST.Branch.from_jsons(data.get(_Global.SAVE_FILE_BRANCHES, {}))
	character_changed.emit(_active)


func load_project(data: Dictionary) -> void:
	var characters: Array[String] = []
	characters.assign(data.get(_Global.SAVE_PROJECT_CHARACTERS, []))

	var conditions: Array[String] = []
	conditions.assign(data.get(_Global.SAVE_PROJECT_CONDITIONS, []))

	var actions: Array[String] = []
	actions.assign(data.get(_Global.SAVE_PROJECT_ACTIONS, []))

	_characters = characters
	_conditions = conditions
	_actions = actions


func save_project(data: Dictionary) -> void:
	data[_Global.SAVE_PROJECT_CHARACTERS] = _characters
	data[_Global.SAVE_PROJECT_CONDITIONS] = _conditions
	data[_Global.SAVE_PROJECT_ACTIONS] = _actions


func save_character(save: Dictionary) -> void:
	save[_Global.SAVE_FILE_NAME] = _active

	var branches := {}
	for id in _branches:
		branches[id] = _branches[id].to_json()
	save[_Global.SAVE_FILE_BRANCHES] = branches

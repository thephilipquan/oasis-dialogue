extends RefCounted

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Visitor := preload("res://addons/oasis_dialogue/model/visitor.gd")
const _IdCollision := preload("res://addons/oasis_dialogue/model/id_collision.gd")
const _SequenceUtils := preload("res://addons/oasis_dialogue/utils/sequence.gd")

signal branch_added(id: int)

var _save_path := ""
var _active := ""
var _characters: Dictionary[String, _AST.Character] = {}
var _conditions: Array[String] = []
var _actions: Array[String] = []


func has_save_path() -> bool:
	return _save_path != ""


func get_save_path() -> String:
	return _save_path


func set_save_path(path: String) -> void:
	_save_path = path


func get_active_character() -> String:
	return _active


func get_characters() -> Dictionary[String, _AST.Character]:
	return _characters.duplicate()


func set_conditions(conditions: Array[String]) -> void:
	_conditions = conditions


func has_condition(condition: String) -> bool:
	return condition in _conditions


func set_actions(actions: Array[String]) -> void:
	_actions = actions


func has_action(action: String) -> bool:
	return action in _actions


func add_branch() -> void:
	if not _active:
		return
	var branches := get_branches()
	var sorted: Array[int] = branches.keys()
	sorted.sort()
	var id := _SequenceUtils.get_next(sorted)
	add_named_branch(id)


func add_named_branch(id: int) -> void:
	if not _active:
		return
	_characters[_active].branches[id] = _AST.Branch.new(id, [], [], [])
	branch_added.emit(id)


func update_branch(id: int, value: _AST.ASTNode) -> void:
	var character := _characters[_active]
	assert(id in character.branches)
	character.branches[id] = value


func get_branch(id: int) -> _AST.ASTNode:
	assert(has_branch(id))
	return _characters[_active].branches[id]


func remove_branch(id: int) -> void:
	var branches := get_branches()
	branches.erase(id)
	_characters[_active].branches = branches


func is_active() -> bool:
	return _active != ""


func has_character(name: String) -> bool:
	return name in _characters


func add_character(name: String) -> void:
	assert(not name in _characters)
	_characters[name] = _AST.Character.new(name, {})


func switch_character(new_active: String) -> void:
	assert(new_active in _characters)
	_active = new_active


func remove_character(force := false) -> void:
	if has_branches() and not force:
		return
	var removed_character := _active
	_characters.erase(_active)
	_active = ""


func rename_character(to: String) -> void:
	assert(_active and not to in _characters)
	_characters[to] = _characters[_active]
	_characters.erase(_active)
	_active = to
	_characters[_active].name = to


func has_branch(id: int) -> bool:
	return id in _characters[_active].branches


func has_branches() -> bool:
	return _characters[_active].branches.size() > 0


## Returns the branches of the [member _active] character.
func get_branches() -> Dictionary[int, _AST.Branch]:
	return _characters[_active].branches.duplicate()


func load_project(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return false
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return false
	from_json(json.data)
	return true


func save_project() -> bool:
	var file := FileAccess.open(_save_path, FileAccess.WRITE)
	if not file:
		return false
	file.store_string(JSON.stringify(to_json()))
	return true


func to_json() -> Dictionary:
	var json := {
		"save_path": _save_path,
		"conditions": _conditions,
		"actions": _actions,
		"characters": (
				_characters.values().map(func(c: _AST.Character): return c.to_json())
				if _characters
				else []
		),
	}
	return json


func from_json(json: Dictionary) -> void:
	_conditions.clear()
	_actions.clear()
	_characters.clear()

	_save_path = json["save_path"]
	_conditions.assign(json["conditions"])
	_actions.assign(json["actions"])
	for c in _AST.Character.from_jsons(json["characters"]):
		_characters[c.name] = c

extends RefCounted

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Visitor := preload("res://addons/oasis_dialogue/model/visitor.gd")
const _IdCollision := preload("res://addons/oasis_dialogue/model/id_collision.gd")
const _SequenceUtils := preload("res://addons/oasis_dialogue/utils/sequence.gd")

signal branch_added(id: int)

var _active := ""
var _characters: Dictionary[String, _AST.Character] = {}
var _conditions: Array[String] = []
var _actions: Array[String] = []


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
		push_warning("Tried to add a branch with no _active character.")
		return
	var branches := get_branches()
	var sorted: Array[int] = branches.keys()
	sorted.sort()
	var id := _SequenceUtils.get_next(sorted)
	add_named_branch(id)


func add_named_branch(id: int) -> void:
	if not _active:
		push_warning("Tried to add a named branch with no _active character.")
		return
	_characters[_active].branches[id] = _AST.ASTNode.new()
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
	_characters[name] = _AST.Character.new({})


func switch_character(new_active: String) -> void:
	assert(new_active in _characters)
	_active = new_active


func remove_character(force := false) -> void:
	if has_branches() and not force:
		push_warning("%s has branches. Pass force as TRUE if you want to delete." % _active)
		return
	var removed_character := _active
	_characters.erase(_active)
	_active = ""


func rename_character(to: String) -> void:
	assert(_active and not to in _characters)
	var old := _active

	_characters[to] = _characters[_active]
	_characters.erase(_active)
	_active = to


func has_branch(id: int) -> bool:
	return id in _characters[_active].branches


func has_branches() -> bool:
	return _characters[_active].branches.size() > 0


## Returns the branches of the [member _active] character.
func get_branches() -> Dictionary[int, _AST.ASTNode]:
	return _characters[_active].branches.duplicate()


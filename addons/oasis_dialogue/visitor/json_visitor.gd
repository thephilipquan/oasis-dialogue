extends "res://addons/oasis_dialogue/visitor/visitor.gd"

var _character: Dictionary[int, Variant] = {}

var _current: Dictionary[String, Variant] = {}
var _stack: Array[Dictionary] = []

var _id := -1
var _in_conditions := false
var _in_actions := false


func _init(character: Dictionary) -> void:
	_character = character


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id
	_push_new()


func visit_annotation(annotation: _AST.Annotation) -> void:
	match annotation.name:
		"rng", "seq":
			_current.type = annotation.name
		"unique":
			_current.unique = true
		_:
			push_warning("unhandled annotation (%s)" % annotation.name)


func visit_prompt(_prompt: _AST.Prompt) -> void:
	_pop_to_root()
	_in_conditions = false
	_in_actions = false
	var prompts: Array = _lazy_get("prompts", [])
	prompts.push_back(_push_new())


func visit_response(_response: _AST.Response) -> void:
	_pop_to_root()
	_in_conditions = false
	_in_actions = false
	var responses: Array = _lazy_get("responses", [])
	responses.push_back(_push_new())


func visit_condition(condition: _AST.Condition) -> void:
	if _in_actions or _in_conditions:
		_pop()
		_in_actions = false
	_in_conditions = true
	var conditions: Array = _lazy_get("conditions", [])
	_push_new()
	_current.name = condition.name
	conditions.push_back(_current)


func visit_action(action: _AST.Action) -> void:
	if _in_actions or _in_conditions:
		_pop()
		_in_conditions = false
	_in_actions = true
	var actions: Array = _lazy_get("actions", [])
	_push_new()
	_current.name = action.name
	actions.push_back(_current)


func visit_stringliteral(value: _AST.StringLiteral) -> void:
	if _in_actions or _in_conditions:
		_pop()
	_current.text = value.value


func visit_numberliteral(value: _AST.NumberLiteral) -> void:
	_current.value = value.value


func cancel() -> void:
	_current = {}
	_stack = []
	_id = -1
	_in_conditions = false
	_in_actions = false



func finish() -> void:
	_pop_to_root()
	_character[_id] = _stack[0]
	cancel()


func _push_new() -> Dictionary:
	_current = {}
	_stack.push_back(_current)
	return _current


func _pop() -> void:
	_stack.pop_back()
	_current = _stack[-1]


func _pop_to_root() -> void:
	while _stack.size() > 1:
		_stack.pop_back()
	_current = _stack[-1]


func _lazy_get(key: String, default: Variant = null) -> Variant:
	if not key in _current:
		_current[key] = default
	return _current[key]

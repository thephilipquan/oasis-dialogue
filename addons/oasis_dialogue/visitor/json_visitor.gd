extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const BRANCH_ANNOTATIONS := "annotations"
const BRANCH_PROMPTS := "prompts"
const BRANCH_RESPONSES := "responses"
const LINE_CONDITIONS := "conditions"
const LINE_ACTIONS := "actions"
const LINE_TEXT := "text"
const KEY_VALUE_LEFT := "name"
const KEY_VALUE_RIGHT := "value"

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
	var annotations: Array = _lazy_get(BRANCH_RESPONSES, [])
	annotations.push_back(annotation.name)


func visit_prompt(_prompt: _AST.Prompt) -> void:
	_pop_to_root()
	_in_conditions = false
	_in_actions = false
	var prompts: Array = _lazy_get(BRANCH_PROMPTS, [])
	prompts.push_back(_push_new())


func visit_response(_response: _AST.Response) -> void:
	_pop_to_root()
	_in_conditions = false
	_in_actions = false
	var responses: Array = _lazy_get(BRANCH_RESPONSES, [])
	responses.push_back(_push_new())


func visit_condition(condition: _AST.Condition) -> void:
	if _in_actions or _in_conditions:
		_pop()
		_in_actions = false
	_in_conditions = true
	var conditions: Array = _lazy_get(LINE_CONDITIONS, [])
	_push_new()
	_current[KEY_VALUE_LEFT] = condition.name
	conditions.push_back(_current)


func visit_action(action: _AST.Action) -> void:
	if _in_actions or _in_conditions:
		_pop()
		_in_conditions = false
	_in_actions = true
	var actions: Array = _lazy_get(LINE_ACTIONS, [])
	_push_new()
	_current[KEY_VALUE_LEFT] = action.name
	actions.push_back(_current)


func visit_stringliteral(value: _AST.StringLiteral) -> void:
	if _in_actions or _in_conditions:
		_pop()
	_current[LINE_TEXT] = value.value


func visit_numberliteral(value: _AST.NumberLiteral) -> void:
	_current[KEY_VALUE_RIGHT] = value.value


func cancel() -> void:
	_current = {}
	_stack = []
	_id = -1
	_in_conditions = false
	_in_actions = false



func finish() -> void:
	_pop_to_root()
	_add_default()
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


func _add_default() -> void:
	var annotations: Array = _lazy_get(BRANCH_ANNOTATIONS, [])
	if annotations.find("seq") == -1 and annotations.find("rng") == -1:
		annotations.push_back("seq")


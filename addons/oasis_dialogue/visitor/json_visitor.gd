extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const BRANCH_ANNOTATIONS := "annotations"
const BRANCH_PROMPTS := "prompts"
const BRANCH_RESPONSES := "responses"
const LINE_CONDITIONS := "conditions"
const LINE_ACTIONS := "actions"
const LINE_KEY := "key"
const KEY_VALUE_LEFT := "name"
const KEY_VALUE_RIGHT := "value"

var _out: Dictionary[int, Variant] = {}
var _character_name := ""
var _create_prompt_key := Callable()
var _create_response_key := Callable()
var _default_annotation := ""
var _is_exclusive_annotation := Callable()

var _current: Dictionary[String, Variant] = {}
var _stack: Array[Dictionary] = []

var _id := -1
var _in_prompt := false
var _in_response := true
var _in_conditions := false
var _in_actions := false
var _prompt_index = -1
var _response_index = -1


func _init(
	out: Dictionary,
	character_name: String,
	create_prompt_key: Callable,
	create_response_key: Callable,
	default_annotation: String,
	is_exclusive_annotation: Callable
) -> void:
	_out = out
	_character_name = character_name
	_create_prompt_key = create_prompt_key
	_create_response_key = create_response_key
	_default_annotation = default_annotation
	_is_exclusive_annotation = is_exclusive_annotation


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id
	_push_new()


func visit_annotation(annotation: _AST.Annotation) -> void:
	var annotations: Array = _lazy_get(BRANCH_ANNOTATIONS, [])
	annotations.push_back(annotation.name)


func visit_prompt(_prompt: _AST.Prompt) -> void:
	_pop_to_root()
	_in_conditions = false
	_in_actions = false
	var prompts: Array = _lazy_get(BRANCH_PROMPTS, [])
	prompts.push_back(_push_new())
	_in_prompt = true
	_prompt_index += 1


func visit_response(_response: _AST.Response) -> void:
	_pop_to_root()
	_in_conditions = false
	_in_actions = false
	var responses: Array = _lazy_get(BRANCH_RESPONSES, [])
	responses.push_back(_push_new())
	_in_prompt = false
	_in_response = true
	_response_index += 1


func visit_condition(condition: _AST.Condition) -> void:
	if _in_conditions:
		_pop()
	_in_conditions = true
	var conditions: Array = _lazy_get(LINE_CONDITIONS, [])
	_push_new()
	_current[KEY_VALUE_LEFT] = condition.name
	conditions.push_back(_current)


func visit_action(action: _AST.Action) -> void:
	if _in_actions:
		_pop()
	_in_actions = true
	var actions: Array = _lazy_get(LINE_ACTIONS, [])
	_push_new()
	_current[KEY_VALUE_LEFT] = action.name
	actions.push_back(_current)


func visit_stringliteral(value: _AST.StringLiteral) -> void:
	if _in_actions or _in_conditions:
		_in_actions = false
		_in_conditions = false
		_pop()

	assert(_in_prompt or _in_response)
	var create_key := Callable()
	var index := -1
	if _in_prompt:
		create_key = _create_prompt_key
		index = _prompt_index
	else:
		create_key = _create_response_key
		index = _response_index

	_current[LINE_KEY] = create_key.call(_character_name, _id, index)


func visit_numberliteral(value: _AST.NumberLiteral) -> void:
	_current[KEY_VALUE_RIGHT] = value.value


func cancel() -> void:
	_current = {}
	_stack = []
	_id = -1
	_in_prompt = false
	_in_response = true
	_in_conditions = false
	_in_actions = false
	_prompt_index = -1
	_response_index = -1



func finish() -> void:
	_pop_to_root()

	if not _has_prompt_annotation():
		_add_default()

	_out[_id] = _stack[0]
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
	annotations.push_back(_default_annotation)


func _has_prompt_annotation() -> bool:
	var annotations: Array = _lazy_get(BRANCH_ANNOTATIONS, [])
	var has := false
	for a in annotations:
		if _is_exclusive_annotation.call(a):
			has = true
			break
	return has

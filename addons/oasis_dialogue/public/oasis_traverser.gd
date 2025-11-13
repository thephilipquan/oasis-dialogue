class_name OasisTraverser
extends RefCounted

## Emitted when the user has interacted via [method next] and the next
## interaction is a prompt spoken by the character.
signal prompt(item: String)

## Emitted when the user has interacted via [method next] and the next
## interaction is to display the list of responses the player can choose.
## [br][br]
## When this is emitted, the traverser is expecting the user to call [method
## next] with the chosen response index.
signal responses(items: Array[String])

## Emitted when the traverser has no more prompts and responses to display.
signal finished


var _branches: Dictionary[int, OasisBranch] = {}
var _controllers: Dictionary[String, OasisTraverserController] = {}
var _translate := Callable()
var _condition_handler := Callable()
var _action_handler := Callable()

var _current: OasisBranch = null
var _p := 0

var _responding := false


func _init(branches: Dictionary[int, OasisBranch], root: int) -> void:
	_branches = branches
	_current = _branches[root]


func init_controllers(controllers: Dictionary[String, OasisTraverserController]) -> void:
	_controllers = controllers


func init_translation(callback: Callable) -> void:
	_translate = callback


func init_condition_handler(callback: Callable) -> void:
	_condition_handler = callback


func init_action_handler(callback: Callable) -> void:
	_action_handler = callback


func get_condition_handler() -> Callable:
	return Callable(_condition_handler)


func get_action_handler() -> Callable:
	return Callable(_action_handler)


func get_current() -> OasisBranch:
	return _current


func get_prompt_index() -> int:
	return _p


func set_prompt_index(index: int) -> void:
	_p = clampi(index, 0, _current.prompts.size())


func branch(id: int) -> void:
	_current = _branches[id]
	_p = 0
	_responding = false


func next(response_index := 0) -> void:
	if _responding:
		_respond(response_index)

	if _has_prompt():
		prompt.emit(_next_prompt())

	if _has_prompt():
		return
	elif _has_responses() and not _responding:
		_responding = true
		responses.emit(_next_responses())
	else:
		finished.emit()


func _respond(response_index: int) -> void:
	if response_index >= _current.responses.size():
		push_warning(
				"response index (%d) outside expected range (%d)" % [
					response_index,
					_current.responses.size(),
				]
		)
		return
	_action_handler.call(self, _current.responses[response_index].actions)


func _has_prompt() -> bool:
	_call_controllers(&"has_prompt")
	return _p < _current.prompts.size()


func _next_prompt() -> String:
	var translated := _translate.call(_current.prompts[_p].key)
	_call_controllers(&"increment_prompt_index")
	_action_handler.call(self, _current.prompts[_p - 1].actions)
	return translated


func _has_responses() -> bool:
	return _current.responses.size() > 0


func _next_responses() -> Array[String]:
	var translated: Array[String] = []
	translated.resize(_current.responses.size())
	for i in translated.size():
		translated[i] = _translate.call(_current.responses[i].key)
	return translated


func _call_controllers(method: StringName) -> void:
	var handled: Array[String] = []
	for annotation in _current.annotations:
		if _controllers[annotation].call(method, self):
			handled.push_back(annotation)
	if handled.size() > 1:
		push_warning(
				"Multiple controllers (%s) handled method (%s). When only one should." %
				[ handled, method ]
		)

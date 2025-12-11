## Used to traverse OasisDialogue during runtime.
##
## When used to traverse, the using class should connect to all signals and call
## [method next] to interact.
## View the
## [url=https://github.com/thephilipquan/oasis-dialogue/blob/feat-docs/example/example.gd#L60]
## example
## [/url]
## on GitHub.
##
## [br][br]
##
## When implementing an [OasisTraverserController], the using class should
## use the exposed getters and [method set_prompt_index] to implement custom
## logic.
class_name OasisTraverser
extends RefCounted

## Emitted when the user has interacted via [method next] and the next
## interaction is a prompt spoken by the character.
signal prompt(item: String)

## Emitted when the user has interacted via [method next] and the next
## interaction is to display the last prompt along with the list of responses
## the player can choose.
## [br][br]
## When this is emitted, the traverser is expecting the next call to
## [method next] with the chosen response index.
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

var _responses: Array[OasisLine] = []
var _responded := false


func _init(branches: Dictionary[int, OasisBranch], root: int) -> void:
	_branches = branches
	_current = _branches[root]


## Sets controllers registered for all branches that are possible to traverse.
##
## Must be called when initialized. Used by [OasisManager].
func init_controllers(controllers: Dictionary[String, OasisTraverserController]) -> void:
	_controllers = controllers


## Sets the callback to use to translate keys.
##
## Must be called when initialized. Used by [OasisManager].
func init_translation(callback: Callable) -> void:
	_translate = callback


## Sets the callback to use to validate conditions.
##
## Must be called when initialized. Used by [OasisManager].
func init_condition_handler(callback: Callable) -> void:
	_condition_handler = callback


## Sets the callback to use to validate conditions.
##
## Must be called when initialized. Used by [OasisManager].
func init_action_handler(callback: Callable) -> void:
	_action_handler = callback


## Returns the callback used to validate conditions.
##
## The callback's signature is equal to
## [method OasisManager.validate_conditions].
func get_condition_handler() -> Callable:
	return Callable(_condition_handler)


## Returns the callback used to execute actions.
##
## The callback's signature is equal to [method OasisManager.handle_actions].
func get_action_handler() -> Callable:
	return Callable(_action_handler)


## Returns the current branch.
func get_current() -> OasisBranch:
	return _current


## Returns the current prompt index.
func get_prompt_index() -> int:
	return _p


## Returns the amount of prompts for the current branch.
##
## [br][br]
##
## Alias for calling [code]get_current().prompts.size()[/code].
func get_prompts_size() -> int:
	return _current.prompts.size()


## Set the prompt_index for this branch.
##
## [br][br]
##
## If the prompt index is set to the current branch's prompts.size() or higher,
## the traverser will determine there [b]is not[/b] another prompt left to
## display, and will continue to show the responses, if they exist.
##
## This should be called when implementing [method
## OasisTraverserController.has_prompt] and [method
## OasisTraverserController.increment_prompt_index].
func set_prompt_index(index: int) -> void:
	_p = clampi(index, 0, _current.prompts.size())


## Tells the traverser to move on to branch [param id].
##
## [br][br]
##
## This should be called when implementing [method OasisManager.handle_actions]
## when encountering the action notated by the writer. Usually this is the
## action [code]branch[/code] itself, but can be whatever the writer chooses in the end.
func branch(id: int) -> void:
	_current_event(&"exit_branch")
	_current = _branches[id]
	_p = 0
	_responses.clear()
	_responded = false
	_current_event(&"enter_branch")


## Tells the traverser to emit the next event, [signal prompt],
## [signal responses], or [signal finished].
##
## [br][br]
##
## Ignores [param response_index] until [signal responses] is emitted, then
## the [b]very next call[/b] chooses the chosen response's actions.
func next(response_index := 0) -> void:
	var prompted := false
	if _responses.size() != 0:
		_responded = true
		_respond(response_index)

	if _has_prompt():
		prompted = true
		prompt.emit(_next_prompt())

	if _has_prompt():
		return

	_responses = _filter_responses()
	if _has_responses() and not _responded:
		responses.emit(_translate_responses())
	elif not prompted:
		_event(&"finish")
		finished.emit()


func _respond(response_index: int) -> void:
	if response_index >= _responses.size():
		push_warning(
				"response index (%d) outside expected range (%d)" % [
					response_index,
					_responses.size(),
				]
		)
		return
	_action_handler.call(self, _responses[response_index].actions)


func _has_prompt() -> bool:
	_current_exclusive_event(&"has_prompt")
	return _p < _current.prompts.size()


func _next_prompt() -> String:
	var current_branch := _current.id

	var translated := _translate.call(_current.prompts[_p].key)
	_action_handler.call(self, _current.prompts[_p].actions)

	# Only increment if we are still on the same branch.
	if _current.id == current_branch:
		_current_exclusive_event(&"increment_prompt_index")

	return translated


func _has_responses() -> bool:
	return _responses.size() > 0


func _filter_responses() -> Array[OasisLine]:
	return _current.responses.filter(
			func(line: OasisLine) -> bool:
				return _condition_handler.call(self, line.conditions)
	)


func _translate_responses() -> Array[String]:
	var translations: Array[String] = []
	translations.assign(_responses.map(
			func(l: OasisLine) -> String:
				return _translate.call(l.key)
	))
	return translations


func _event(method: StringName) -> void:
	for key in _controllers.keys():
		_controllers[key].call(method, self)


func _current_event(method: StringName) -> void:
	for a in _current.annotations:
		if not a in _controllers:
			# Warning already emitted in OasisManager:171.
			continue

		_controllers[a].call(method, self)


func _current_exclusive_event(method: StringName) -> void:
	var handled: Array[String] = []
	for annotation in _current.annotations:
		if not annotation in _controllers:
			# Warning already emitted in OasisManager:171.
			continue

		if _controllers[annotation].call(method, self):
			handled.push_back(annotation)

	if handled.size() > 1:
		push_warning(
				"Multiple controllers (%s) handled method (%s). When only one should." %
				[ handled, method ]
		)

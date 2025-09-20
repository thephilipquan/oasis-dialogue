extends "res://addons/oasis_dialogue/model/visitor.gd"

var _action: _AST.Action = null


func _init(action: _AST.Action) -> void:
	_action = action


func visit_prompt(prompt: _AST.Prompt) -> void:
	var to_remove: Array[int] = []
	for i in prompt.actions.size():
		var prompt_action: _AST.Action = prompt.actions[i]
		if _action.equals(prompt_action):
			to_remove.push_back(i)
	if to_remove:
		to_remove.map(func(i: int): prompt.actions.pop_at(i))
		to_remove.clear()


func visit_response(response: _AST.Response) -> void:
	var to_remove: Array[int] = []
	for i in response.actions.size():
		var response_action: _AST.Action = response.actions[i]
		if _action.equals(response_action):
			to_remove.push_back(i)
	if to_remove:
		to_remove.map(func(i: int): response.actions.pop_at(i))
		to_remove.clear()


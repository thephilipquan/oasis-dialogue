extends OasisTraverserController


func get_annotation() -> String:
	return "rng"


func has_prompt(t: OasisTraverser) -> bool:
	if t.get_prompt_index() >= t.get_prompts_size():
		return false

	var prompts := t._current.prompts.filter(
			func(l: OasisLine) -> bool:
				return t.get_condition_handler().call(t, l.conditions)
	)
	var i := randi_range(0, prompts.size() - 1)
	t.set_prompt_index(i)
	return true


func increment_prompt_index(t: OasisTraverser) -> bool:
	t.set_prompt_index(t.get_prompts_size())
	return true

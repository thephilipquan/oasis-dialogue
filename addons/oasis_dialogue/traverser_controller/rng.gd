extends OasisTraverserController


func has_prompt(t: OasisTraverser) -> bool:
	var prompts := t._current.prompts.filter(
			func(l: OasisLine) -> bool:
				return t.get_condition_handler().call(t, l.conditions)
	)
	var i := randi_range(0, prompts.size() - 1)
	t.set_prompt_index(i)
	return true


func increment_prompt_index(t: OasisTraverser) -> bool:
	t.set_prompt_index(t.get_current().prompts.size())
	return true

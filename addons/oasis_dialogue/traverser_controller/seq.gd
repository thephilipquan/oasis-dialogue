extends OasisTraverserController


func has_prompt(t: OasisTraverser) -> bool:
	var current := t.get_current()
	var condition_handler := t.get_condition_handler()
	var p := t.get_prompt_index()
	while (
		p < current.prompts.size() and
		not condition_handler.call(current.prompts[p].conditions)
	):
		p += 1
	t.set_prompt_index(p)
	return true


func increment_prompt_index(t: OasisTraverser) -> bool:
	t.set_prompt_index(t.get_prompt_index() + 1)
	return true

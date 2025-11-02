## A controller for [OasisTraverser] to show each valid prompt in sequential
## order for branches annotated @seq.
extends OasisTraverserController


func get_annotation() -> String:
	return "seq"


func has_prompt(t: OasisTraverser) -> bool:
	var current := t.get_current()
	var condition_handler := t.get_condition_handler()
	var p := t.get_prompt_index()

	## Increment till we find a valid prompt.
	while (
		p < current.prompts.size() and
		not condition_handler.call(t, current.prompts[p].conditions)
	):
		p += 1
	t.set_prompt_index(p)

	# Must return true when overriding this and any overridable method in
	# OasisTraverserController that returns a bool.
	return true


func increment_prompt_index(t: OasisTraverser) -> bool:
	# We want to show every prompt in the list so we just increment by 1.
	t.set_prompt_index(t.get_prompt_index() + 1)
	return true

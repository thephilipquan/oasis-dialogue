## A controller for [OasisTraverser] to show one random valid prompt for
## branches annotated @rng.
extends OasisTraverserController


func get_annotation() -> String:
	return "rng"


func has_prompt(t: OasisTraverser) -> bool:
	# Look at increment_prompt_index implementation.
	# If the prompt index is >= the amount of prompts, we have already shown
	# a prompt so we exit.
	if t.get_prompt_index() >= t.get_prompts_size():
		return true

	# Before choosing a random prompt, we filter prompts that are allowed to be
	# shown by calling the condition_handler on all prompts.
	# See OasisManager.validate_conditions for the callback's signature.
	var prompts := t._current.prompts.filter(
			func(l: OasisLine) -> bool:
				return t.get_condition_handler().call(t, l.conditions)
	)

	var i := randi_range(0, prompts.size() - 1)
	# When the prompt index is set < prompts.size(), the traverser will
	# determine there is a next prompt.
	t.set_prompt_index(i)

	# Must return true when overriding this and any overridable method in
	# OasisTraverserController that returns a bool.
	return true


func increment_prompt_index(t: OasisTraverser) -> bool:
	# The purpose of the controller is to show one prompt, then the list of
	# responses. For the traverser to determine there are no more prompts to
	# display, the prompt index must be >= prompts.size().
	t.set_prompt_index(t.get_prompts_size())
	return true

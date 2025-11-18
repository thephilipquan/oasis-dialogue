@abstract
class_name OasisTraverserController
extends Node

@abstract
func get_annotation() -> String

func has_prompt(traverser: OasisTraverser) -> bool:
	return false

func increment_prompt_index(traverser: OasisTraverser) -> bool:
	return false

func finish(traverser: OasisTraverser) -> void:
	pass

func enter_branch(traverser: OasisTraverser) -> void:
	pass

func exit_branch(traverser: OasisTraverser) -> void:
	pass

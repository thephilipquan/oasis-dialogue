@abstract
class_name OasisTraverserController
extends Node

@abstract
func get_annotation() -> String

func reachable_branches_set(traverser: OasisTraverser) -> void:
	pass

func has_prompt(traverser: OasisTraverser) -> bool:
	return false

func increment_prompt_index(traverser: OasisTraverser) -> bool:
	return false

func start(traverser: OasisTraverser) -> void:
	pass

func finish(traverser: OasisTraverser) -> void:
	pass

func visit(traverser: OasisTraverser) -> void:
	pass

@abstract
class_name OasisTraverserController
extends Node

@abstract
func get_annotation() -> String


func reachable_branches_set(traverser: OasisTraverser) -> bool:
	return false

func has_prompt(traverser: OasisTraverser) -> bool:
	return false

func increment_prompt_index(traverser: OasisTraverser) -> bool:
	return false

func start(traverser: OasisTraverser) -> bool:
	return false

func finish(traverser: OasisTraverser) -> bool:
	return false

func visit(traverser: OasisTraverser) -> bool:
	return false

extends OasisManager


func _translate(key: String) -> String:
	var translated :=  tr(key)
	return translated


func _validate_conditions(_conditions: Array[OasisKeyValue]) -> bool:
	return true


func _handle_actions(traverser: OasisTraverser, actions: Array[OasisKeyValue]) -> void:
	for action in actions:
		if action.key == "branch":
			traverser.branch(action.value)

extends OasisManager

@export
var track_controller: OasisTraverserController = null

var is_weird := false
var seen: Dictionary[int, int] = {}


func _ready() -> void:
	track_controller.init_seen(see)
	track_controller.init_clear_seen(clear_seen)


func see(branch: int) -> void:
	if not branch in seen:
		seen[branch] = 1
	else:
		seen[branch] = seen[branch] + 1


func clear_seen() -> void:
	seen.clear()


func _translate(key: String) -> String:
	var translated :=  tr(key)
	return translated


func _validate_conditions(traverser: OasisTraverser, conditions: Array[OasisKeyValue]) -> bool:
	var is_valid := true
	for condition in conditions:
		match condition.key:
			"not_seen":
				is_valid = not condition.value in seen
			"seen":
				is_valid = condition.value in seen
			"is_weird":
				is_valid = is_weird
			"seen_count":
				var id: int = traverser.get_current().id
				is_valid = seen.get(id, 0) == condition.value
			"seen_more_than":
				var id: int = traverser.get_current().id
				is_valid = seen.get(id, 0) > condition.value
		if not is_valid:
			break
	return is_valid


func _handle_actions(traverser: OasisTraverser, actions: Array[OasisKeyValue]) -> void:
	for action in actions:
		match action.key:
			"branch":
				traverser.branch(action.value)
			"weird":
				is_weird = true

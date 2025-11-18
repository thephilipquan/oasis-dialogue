extends OasisTraverserController


var _seen := Callable()
var _clear_seen := Callable()

func init_seen(callback: Callable) -> void:
	_seen = callback


func init_clear_seen(callback: Callable) -> void:
	_clear_seen = callback


func get_annotation() -> String:
	return "track"


func exit_branch(traverser: OasisTraverser) -> void:
	_seen.call(traverser.get_current().id)


func finish(_traverser: OasisTraverser) -> void:
	_clear_seen.call()

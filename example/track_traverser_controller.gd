extends OasisTraverserController


var _seen := Callable()
var _clear_seen := Callable()


# Init methods.
func init_seen(callback: Callable) -> void:
	_seen = callback


# Init methods.
func init_clear_seen(callback: Callable) -> void:
	_clear_seen = callback


func get_annotation() -> String:
	# This controller handles the @track annotation.
	return "track"


# We want to track when we've seen a branch "after" we see it, so we hook into
# this event, which is called when a branch is exited.
# See addons/oasis_dialogue/public/oasis_traverser_controller.gd for more
# exposed events.
func exit_branch(traverser: OasisTraverser) -> void:
	_seen.call(traverser.get_current().id)


# Emitted when we have reached the end of dialogue.
#
# For the example, we simply reset.
func finish(_traverser: OasisTraverser) -> void:
	_clear_seen.call()

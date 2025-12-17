# The OasisManager is where you, the developer, will spend all your time.
# This is where you bridge the writer's intentions to in game mechanics.
# Whether the writer wants to give the player gold, read an npc's mood,
# determine if it is night or day - this is all done here.
#
# Depending on the number of conditions and actions the writer creates, this
# class may get long, but don't confuse the length as being complex.
# You could make multiple managers for different scenes that handle only the
# conditions and actions needed in that scene, but don't preoptimize and do that
# from the start.
#
# You can view any class here in addons/oasis_dialogue/public/ for details.
extends OasisManager

# There is a custom annotation @track that the writer has created to "track"
# the amount of times that branch is visited. The writer has some dialogue logic
# that needs this information. To implement this, a track_traverser_controller.gd
# was added as a child to this node within example.tscn, as all custom
# oasis_traverser_controllers must be added as children of an OasisManager to
# function.
#
# All related code to @track will be commented with '# @track'.

# @track
@export
var track_controller: OasisTraverserController = null

# A condition that represents the the conversation got weird. In an actual game,
# this might actually be checked by `fred.mood == Mood.WEIRDED_OUT` instead of
# this member.
var is_weird := false

# @track
var seen: Dictionary[int, int] = {}


# @track
func _ready() -> void:
	track_controller.init_seen(see)
	track_controller.init_clear_seen(clear_seen)


# @track
func see(branch: int) -> void:
	if not branch in seen:
		seen[branch] = 1
	else:
		seen[branch] = seen[branch] + 1


# @track
func clear_seen() -> void:
	seen.clear()


# One of the abstract methods you must override.
func translate(key: String) -> String:
	var translated := tr(key)
	return translated


# One of the abstract methods you must override.
func validate_conditions(traverser: OasisTraverser, conditions: Array[OasisKeyValue]) -> bool:
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


# One of the abstract methods you must override.
func handle_actions(traverser: OasisTraverser, actions: Array[OasisKeyValue]) -> void:
	for action in actions:
		match action.key:
			"branch":
				traverser.branch(action.value)
			"weird":
				is_weird = true
			"root":
				get_character().set_root(action.value)

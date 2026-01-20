## The entry point for starting a dialogue with a character.
##
## Call [method start] to begin dialogue. There must be a corresponding
## [OasisManager] in the scene to handle the [member character]. All
## [b]properties[/b] must be initialized.
##
## [br][br]
##
## See also [OasisManager] and [OasisTraverser].
class_name OasisCharacter
extends Node

const _NodeUtils := preload("res://addons/oasis_dialogue/utils/node_utils.gd")

## The manager for this character.
## [br][br]
## If this variable isn't set, it will look for a manager starting from the
## root node of the project.
## Therefore, setting this directly is recommended when working with multiple
## managers.
##
## If your manager is registered as an autoload, then ignore setting this.
@export
var manager: OasisManager = null
## The name of the character that must match a character found in
## [member OasisManager.json_path].
@export
var character: String = ""
## The starting branch id of the dialogue. Usually this is [code]0[/code] at
## the very start of the game.
## [br][br]
## You should set this member when loading saved data.
@export
var root := 0


func _ready() -> void:
	if not manager:
		manager = _NodeUtils.find_type(get_tree().root, OasisManager)


## Returns an [OasisTraverser] for the given [member character] starting from
## branch [member root]. Returns [code]null[/code] if
## [method OasisManager.get_reachable_branches] fails.
func start() -> OasisTraverser:
	var traverser := manager.get_reachable_branches(self)
	return traverser


func set_root(new_root: int) -> void:
	root = new_root


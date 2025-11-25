class_name OasisCharacter
extends Node

const _NodeUtils := preload("res://addons/oasis_dialogue/utils/node_utils.gd")

# where do they get the manager? search from root if null. If autoload, its ez fast. It not, then
# itll take a while. To optimize, they set it directly if not autoload.
## The manager for this character.
## [br][br]
## If your manager is local to this scene, set this directly to save on
## performance. If this variable isn't set, it will look for a manager starting
## from the root of the whole project. If the manager is registered as an
## autoload, then you can ignore setting this.
@export
var manager: OasisManager = null
@export
var character: String = ""
@export
var root := 0


func _ready() -> void:
	if not manager:
		manager = _NodeUtils.find_type(get_tree().root, OasisManager)


## Returns an [OasisTraverser] for the given [member character] starting from branch [member root].
## [br][br]
## [code]null[/code] will be returned in cases of invalid setup such as...
## [br]
## * The [OasisManager] for this character's [member OasisManager.json_path] was not set.
## [br]
## * [member character] does not exist at [member OasisManager.json_path]
## [br]
## * [member root] was not found.
func start() -> OasisTraverser:
	var traverser := manager.get_reachable_branches(character, root)
	return traverser

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
var _manager: OasisManager = null
@export
var _character: String = ""
@export
var _root := 0


func _ready() -> void:
	if not _manager:
		_manager = _NodeUtils.find_type(get_tree().root, OasisManager)


## Returns an [OasisTraverser] for the given [member _character] starting from [member _root].
## [br][br]
## [code]null[/code] will be returned in cases of invalid setup such as...
## [br]
## * The [OasisManager] for this character's [member OasisManager._json_path] was not set.
## [br]
## * [member _character] does not exist at [member OasisManager._json_path]
## [br]
## * [member _root] was not found.
func start() -> OasisTraverser:
	var traverser := _manager.get_reachable_branches(_character, _root)
	return traverser

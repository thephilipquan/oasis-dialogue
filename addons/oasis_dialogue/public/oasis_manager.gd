## A node responsible for both loading Oasis json files and performing runtime
## condition validation and action execution for oasis dialogue.
##
## An OasisManager can manage one to many [OasisCharacter]s depending on the
## [member json_path] specified.
## [br][br]
## Any [OasisTraverserController]s to be registered [b]must be added as a
## child[/b] of this manager.
##
## [br][br]
## View the
## [url=https://github.com/thephilipquan/oasis-dialogue/blob/feat-docs/example/example_dialogue_manager.gd]
## example[/url] on GitHub.
@abstract
class_name OasisManager
extends Node

const _Global := preload("res://addons/oasis_dialogue/global.gd")
const _JsonFile := preload("res://addons/oasis_dialogue/io/json_file.gd")
const _JsonValidator := preload("res://addons/oasis_dialogue/model/oasis_json_validator.gd")

## The path to the directory of json files or a single json_file.
## [br][br]
## The path can be any pathing supported by [method FileAccess.open].
##
## If registered as an autoload, you should set this within
## [method Node._ready].
##
## [codeblock]
## # Path to a file containing all characters.
## res://dialogue.json
##
## # Path to a single character's file. This is exported via the directory
## # export option from the dialogue editor.
## res://dialogue/frank.json
##
## # Path to a directory with all character's json files.
## res://dialogue
## [/codeblock]
##
## [i]Concerning the directory export[/i] - Setting the path to a specific
## character's file vs the directory is a matter of operational preference.
##
## For most games, exporting all characters to a single file is the best option
## for ease of use.
@export
var json_path := "res://"

var _controllers: Dictionary[String, OasisTraverserController] = {}
var _last_character: OasisCharacter = null


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		_controllers.merge(_load_default_controllers())
		_controllers.merge(_get_child_controllers(), true)


## Return an [OasisTraverser] with all reachable branches for the given [param character] starting
## from branch [param from] at the file specified via [member json_path].
func get_reachable_branches(character: OasisCharacter) -> OasisTraverser:
	var character_name := character.character.to_lower()
	if not json_path:
		push_warning("path not set")
		return null

	var data: Dictionary[int, OasisBranch] = _load_character_dialogue(character_name)
	if not data:
		return null

	if not character.root in data:
		push_warning("OasisDialogueBranch %d not found in data. Are you sure its a valid branch id?" % character.root)
		return null

	var reachable_branches: Dictionary[int, OasisBranch] = _get_reachable_branches(data, character.root)
	var annotations := _collect_reachable_annotations(reachable_branches)
	var controllers := _filter_controllers(annotations)

	var traverser := OasisTraverser.new(reachable_branches, character.root)
	traverser.init_controllers(controllers)
	traverser.init_translation(translate)
	traverser.init_condition_handler(validate_conditions)
	traverser.init_action_handler(handle_actions)

	_last_character = character
	return traverser


func _load_character_dialogue(character: String) -> Dictionary[int, OasisBranch]:
	if not json_path:
		push_warning("Failed to _load_character_dialogue oasis dialogue json because no json path specified. Exiting.")
		return {}

	var data := {}
	var file := _JsonFile.new()
	var dir := DirAccess.open(json_path)
	if dir:
		var character_path := json_path.path_join("%s.json" % character)
		if not FileAccess.file_exists(character_path):
			push_warning("Detected set path as a directory but %s does not exist. Exiting" % character_path)
			return {}
		file.load(character_path)
		data = file.get_loaded_data()
	else:
		file.load(json_path)
		data = file.get_loaded_data()
		var is_character_file = data.keys().all(func(k: String) -> bool: return k.is_valid_int())
		var path_file_name := json_path.get_file().get_basename()
		if is_character_file and character != path_file_name:
			push_warning("Detected set path as a character file but set path %s doesn't match character name: %s" % [json_path, path_file_name])
			return {}
		if not is_character_file:
			# json_path is a single file with all characters.
			if not character in data:
				push_warning("Detected set path as a file with all character, but %s does not exist. Exiting" % character)
				return {}
			data = data[character]

	if not _JsonValidator.validate_character_json(data):
		return {}

	var branches: Dictionary[int, OasisBranch] = {}
	for key in data:
		var id := int(key)
		var branch := OasisBranch.from_json(data[key])
		branch.init_id(id)
		branches[id] = branch

	return branches


func _get_reachable_branches(branches: Dictionary[int, OasisBranch], root: int) -> Dictionary[int, OasisBranch]:
	var stack: Array[int] = []
	var seen: Dictionary[int, bool] = {} # dummy bool value.
	stack.push_back(root)
	seen[root] = true

	while stack:
		var next := stack.pop_back()

		# Trying to branch to a non-existing branch. Warning is emitted to user
		# at end of this method.
		if not next in branches:
			continue

		var branch := branches[next]
		for prompt in branch.prompts:
			_append_unseen_branches(stack, seen, prompt.actions)
		for response in branch.responses:
			_append_unseen_branches(stack, seen, response.actions)

	var reachable_branches: Dictionary[int, OasisBranch] = {}
	for id in seen.keys():
		if not id in branches:
			push_warning("BUG: trying to branch to a non-existing branch %d. Skipping." % id)
			continue
		reachable_branches[id] = branches[id]
	return reachable_branches


func _append_unseen_branches(stack: Array[int], seen: Dictionary[int, bool], actions: Array[OasisKeyValue]) -> void:
	for action in actions:
		if action.key != _Global.CONNECT_BRANCH_KEYWORD:
			continue
		if action.value in seen:
			continue
		stack.push_back(action.value)
		seen[action.value] = true


func _collect_reachable_annotations(branches: Dictionary[int, OasisBranch]) -> Array[String]:
	var annotations: Array[String] = []
	var seen: Dictionary[String, bool] = {} # Dummy value.
	for branch in branches.values():
		for a in branch.annotations:
			if not a in seen:
				annotations.push_back(a)
				seen[a] = true
	return annotations


func _load_default_controllers() -> Dictionary[String, OasisTraverserController]:
	var controllers: Dictionary[String, OasisTraverserController] = {}

	var seq_controller := preload("res://addons/oasis_dialogue/traverser_controller/seq.gd").new()
	controllers[seq_controller.get_annotation()] = seq_controller

	var rng_controller := preload("res://addons/oasis_dialogue/traverser_controller/rng.gd").new()
	controllers[rng_controller.get_annotation()] = rng_controller

	return controllers


func _get_child_controllers() -> Dictionary[String, OasisTraverserController]:
	var controllers: Dictionary[String, OasisTraverserController] = {}
	for child in get_children():
		if is_instance_of(child, OasisTraverserController):
			var cast := child as OasisTraverserController
			controllers[cast.get_annotation()] = cast
	return controllers


func _filter_controllers(annotations: Array[String]) -> Dictionary[String, OasisTraverserController]:
	var controllers: Dictionary[String, OasisTraverserController] = {}
	for annotation in annotations:
		if annotation in _controllers:
			controllers[annotation] = _controllers[annotation]
		else:
			push_warning(
					"No controller found to handle annotation (%s). Provide a OasisTraverserController and add it as a child of this node (%s)"
					% [annotation, name]
			)
	return controllers

## Returns the translation for the key.
##
## For most cases, this involves simply calling [method Object.tr].
## [codeblock]
## func translate(key: String) -> String:
## 	return tr(key)
## [/codeblock]
@abstract
func translate(key: String) -> String

## Returns true if all conditions evalutate to true at runtime.
## [codeblock]
## # Example implementation.
## func validate_conditions(traverser: OasisTraverser, conditions: Array[OasisKeyValue]) -> bool:
## 	var result := true
## 	for c in conditions:
## 		if c.key = "has_gold":
## 			# Player is a class member set by any means.
## 			result = player.gold >= c.value
## 		elif c.key = "weapon_is_broken":
## 			result = player.weapon.durability == 0
## 		if not result:
## 			break
## 	return result
##
## # If no conditions...
## func validate_conditions(_traverser: OasisTraverser, _conditions: Array[OasisKeyValue]) -> bool:
## 	# Simply return true.
## 	return true
## [/codeblock]
@abstract
func validate_conditions(traverser: OasisTraverser, conditions: Array[OasisKeyValue]) -> bool

## Called when a prompt is displayed or a response is chosen at runtime.
## [br][br]
## You [b]must[/b] implement the action the writer designated as the
## [code]branch[/code] action.
##
## [codeblock]
## # Example implementation.
## func handle_actions(traverser: OasisTraverser, actions: Array[OasisKeyValue]) -> void:
## 	for a in actions:
## 		if a.key = "heal":
##			# Player is a class member set by any means.
## 			player.health += a.value
## 		elif a.key = "give_magic_sword":
## 			player.give_item(ItemFactory.create(Items.MAGIC_SWORD))
## 		# The designated 'branch' action.
## 		elif a = "branch":
## 			traverser.branch(a.value)
## [/codeblock]
@abstract
func handle_actions(traverser: OasisTraverser, actions: Array[OasisKeyValue]) -> void


## Returns the current or last character traversed.
func get_character() -> OasisCharacter:
	return _last_character

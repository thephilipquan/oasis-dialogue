class_name OasisManager
extends Node

const _Global := preload("res://addons/oasis_dialogue/global.gd")
const _JsonFile := preload("res://addons/oasis_dialogue/io/json_file.gd")
const _JsonValidator := preload("res://addons/oasis_dialogue/model/oasis_json_validator.gd")

## The path to the directory of json_files or a single json_file.
## [br][br]
## [b]single file example[/b]
## [br]
## [code]res://dialogue.json[/code]
## [br]
## [code]res://dialogue/frank.json[/code]
## [br][br]
## [b]directory example[/b]
## [br]
## [code]res://dialogue[/code]
@export
var json_path := "res://"

var _controllers: Dictionary[String, OasisTraverserController] = {}


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		_controllers.merge(_load_default_controllers())
		_controllers.merge(_get_child_controllers(), true)


## Return an [OasisTraverer] with all reachable branches for the given [param character] starting
## from branch [param from] at the file specified via [member _json_path].
func get_reachable_branches(character: String, from: int) -> OasisTraverser:
	character = character.to_lower()
	if not json_path:
		push_warning("path not set")
		return null

	var data: Dictionary[int, OasisBranch] = _load_character_dialogue(character)
	if not data:
		return null

	if not from in data:
		push_warning("OasisDialogueBranch %d not found in data. Are you sure its a valid branch id?" % from)
		return null

	var reachable_branches: Dictionary[int, OasisBranch] = _get_reachable_branches(data, from)
	var annotations := _collect_reachable_annotations(reachable_branches)
	var controllers := _filter_controllers(annotations)

	var traverser := OasisTraverser.new(reachable_branches, from)
	traverser.init_controllers(controllers)
	traverser.init_translation(translate)
	traverser.init_condition_handler(validate_conditions)
	traverser.init_action_handler(handle_actions)
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


func _translate(key: String) -> String:
	return ""


func _validate_conditions(traverser: OasisTraverser, conditions: Array[OasisKeyValue]) -> bool:
	return true


func _handle_actions(traverser: OasisTraverser, conditions: Array[OasisKeyValue]) -> void:
	pass

@tool
extends Button

const REGISTRY_KEY := "add_branch_button"

const _Graph := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _RemoveCharacterButton := preload("res://addons/oasis_dialogue/canvas/remove_character_button.gd")
const _Sequence := preload("res://addons/oasis_dialogue/utils/sequence_utils.gd")

signal branch_added(id: int)

var _get_branch_ids := Callable()


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var graph: _Graph = registry.at(_Graph.REGISTRY_KEY)
	init_get_branch_ids(graph.get_branch_ids)

	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	manager.character_loaded.connect(show.unbind(1))

	var remove_character: _RemoveCharacterButton = registry.at(_RemoveCharacterButton.REGISTRY_KEY)
	remove_character.character_removed.connect(hide)


func init_get_branch_ids(callback: Callable) -> void:
	_get_branch_ids = callback


func _ready() -> void:
	button_up.connect(_on_button_up)


func _on_button_up() -> void:
	var ids: Array[int] = _get_branch_ids.call()
	ids.sort()
	var next := _Sequence.get_next_int(ids)
	branch_added.emit(next)

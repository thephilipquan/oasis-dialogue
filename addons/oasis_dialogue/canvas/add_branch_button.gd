@tool
extends Button

const REGISTRY_KEY := "add_branch_button"

const _Model := preload("res://addons/oasis_dialogue/model/model.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _RemoveCharacterButton := preload("res://addons/oasis_dialogue/canvas/remove_character_button.gd")
const _Sequence := preload("res://addons/oasis_dialogue/utils/sequence_utils.gd")

signal branch_added(id: int)

var _model: _Model = null


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	_model = registry.at(_Model.REGISTRY_KEY)

	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	manager.file_loaded.connect(show.unbind(1))

	var remove_character: _RemoveCharacterButton = registry.at(_RemoveCharacterButton.REGISTRY_KEY)
	remove_character.character_removed.connect(hide)


func _ready() -> void:
	button_up.connect(_on_button_up)


func _on_button_up() -> void:
	var ids := _model.get_branch_ids()
	ids.sort()
	var next := _Sequence.get_next_int(ids)
	branch_added.emit(next)

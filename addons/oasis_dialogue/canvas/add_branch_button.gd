@tool
extends Button

const _Model := preload("res://addons/oasis_dialogue/model/model.gd")
const _Sequence := preload("res://addons/oasis_dialogue/utils/sequence_utils.gd")

signal branch_added(id: int)

var _model: _Model = null


func _ready() -> void:
	button_up.connect(_on_button_up)


func init(model: _Model) -> void:
	_model = model


func _on_button_up() -> void:
	var ids := _model.get_branch_ids()
	ids.sort()
	var next := _Sequence.get_next_int(ids)
	branch_added.emit(next)


func _on_model_character_changed(name: String) -> void:
	visible = name != ""

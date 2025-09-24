@tool
extends Button

signal branch_added(id: int)

const _Model := preload("res://addons/oasis_dialogue/model/model.gd")

@export
var _model: _Model = null


func _ready() -> void:
	button_up.connect(_on_button_up)


func _on_button_up() -> void:
	if not _model.get_character_count() > 0:
		#_update_status("Please add a character first.", _Duration.SHORT)
		return

	if not _model.get_active_character() != "":
		#_update_status("Please select a character.", _Duration.SHORT)
		return

	var ids := _model.get_branch_ids()
	ids.sort()
	var next := get_next(ids)
	branch_added.emit(next)


func get_next(sorted: Array[int]) -> int:
	var expected := 0
	for x in sorted:
		if x != expected:
			break
		expected += 1
	return expected


func _on_model_character_changed(name: String) -> void:
	visible = name != ""

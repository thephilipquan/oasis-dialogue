@tool
extends Button

const _Model := preload("res://addons/oasis_dialogue/model/model.gd")
const _ConfirmDialog := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.gd")

signal character_removed

var _confirm_dialog_factory := Callable()

var _model: _Model = null


func _ready() -> void:
	button_up.connect(_on_button_up)


func init(model: _Model, confirm_dialog_factory: Callable) -> void:
	_model = model
	_confirm_dialog_factory = confirm_dialog_factory


func _on_button_up() -> void:
	if _model.get_branch_count() > 0:
		var dialog: _ConfirmDialog = _confirm_dialog_factory.call()
		var character := _model.get_active_character()
		dialog.set_message("%s has _branches. Are you sure you want to remove %s" % [character, character])
		dialog.set_cancel_label("cancel")
		dialog.set_confirm_label("delete")
		dialog.canceled.connect(_on_dialog_canceled.bind(dialog))
		dialog.confirmed.connect(_on_dialog_confirmed.bind(dialog))
	else:
		character_removed.emit()


func _on_dialog_canceled(dialog: Control) -> void:
	dialog.queue_free()
	dialog.get_parent().remove_child(dialog)


func _on_dialog_confirmed(dialog: Control) -> void:
	_on_dialog_canceled(dialog)
	character_removed.emit()


func _on_model_character_changed(new_name: String) -> void:
	visible = new_name != ""

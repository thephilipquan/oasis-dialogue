@tool
extends Button

const _ConfirmDialog := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.gd")

signal character_removed

var _get_branch_count := Callable()
var _get_active_character := Callable()
var _confirm_dialog_factory := Callable()


func _ready() -> void:
	button_up.connect(_on_button_up)


func init_get_branch_count(callback: Callable) -> void:
	_get_branch_count = callback


func init_get_active_character(callback: Callable) -> void:
	_get_active_character = callback


func init_confirm_dialog_factory(callback: Callable) -> void:
	_confirm_dialog_factory = callback


func _on_button_up() -> void:
	if _get_branch_count.call() > 0:
		var dialog: _ConfirmDialog = _confirm_dialog_factory.call()
		var character := _get_active_character.call()
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

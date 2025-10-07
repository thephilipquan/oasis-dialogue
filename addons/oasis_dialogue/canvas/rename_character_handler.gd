extends RefCounted

const _InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.gd")

signal character_renamed(name: String)

## [code]func() -> String[/code]
var _get_active_character := Callable()
## [code]func() -> InputDialog[/code]
var _input_dialog_factory := Callable()
## [code]func(name: String) -> bool[/code]
var _can_rename_to := Callable()


func init_get_active_character(callback: Callable) -> void:
	_get_active_character = callback


func init_input_dialog_factory(callback: Callable) -> void:
	_input_dialog_factory = callback


func init_can_rename_to(callback: Callable) -> void:
	_can_rename_to = callback


func rename() -> void:
	var dialog: _InputDialog = _input_dialog_factory.call()
	dialog.set_placeholder_text("Rename %s to..." % _get_active_character.call())
	dialog.set_validation(_validate)
	dialog.set_cancel_label("cancel")
	dialog.set_confirm_label("rename")
	dialog.canceled.connect(_on_dialog_canceled.bind(dialog))
	dialog.confirmed.connect(_on_dialog_confirmed.bind(dialog))


func _on_dialog_canceled(dialog: Control) -> void:
	dialog.get_parent().remove_child(dialog)
	dialog.queue_free()


func _on_dialog_confirmed(name: String, dialog: Control) -> void:
	_on_dialog_canceled(dialog)
	character_renamed.emit(name)


func _validate(name: String) -> String:
	var message := ""
	if not _can_rename_to.call(name):
		message = "%s already exists." % name
	return message

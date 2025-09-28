extends RefCounted

const _Model := preload("res://addons/oasis_dialogue/model/model.gd")
const _InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.gd")

signal character_renamed(name: String)

var _input_dialog_factory := Callable()
var _model: _Model = null


func _init(model: _Model, input_dialog_factory: Callable) -> void:
	_model = model
	_input_dialog_factory = input_dialog_factory


func rename() -> void:
	var dialog: _InputDialog = _input_dialog_factory.call()
	dialog.set_placeholder_text("Renaming %s to..." % _model.get_active_character())
	dialog.set_validation(_validate)
	dialog.set_confirm_label("Rename")
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
	if _model.has_character(name):
		message = "%s already exists." % name
	return message

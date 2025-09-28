@tool
extends Button

const _InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.gd")
const _Model := preload("res://addons/oasis_dialogue/model/model.gd")

signal character_added(name: String)

var _model: _Model = null
var _input_dialog_factory := Callable()


func _ready() -> void:
	button_up.connect(_on_button_up)


func init(model: _Model, input_dialog_factory: Callable) -> void:
	_model = model
	_input_dialog_factory = input_dialog_factory


func _on_button_up() -> void:
	var dialog: _InputDialog = _input_dialog_factory.call()
	dialog.set_placeholder_text("Enter character name...")
	dialog.set_validation(_validate)
	dialog.set_confirm_label("Add")
	dialog.canceled.connect(_on_dialog_canceled.bind(dialog))
	dialog.confirmed.connect(_on_dialog_confirmed.bind(dialog))


func _on_dialog_canceled(dialog: Control) -> void:
	dialog.queue_free()
	dialog.get_parent().remove_child(dialog)


func _on_dialog_confirmed(name: String, dialog: Control) -> void:
	_on_dialog_canceled(dialog)
	character_added.emit(name)


func _validate(name: String) -> String:
	var message := ""
	if name == "":
		message = "Character cannot be a blank."
	elif _model.has_character(name):
		message = "%s already exists." % name
	return message

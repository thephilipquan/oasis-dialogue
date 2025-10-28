@tool
extends TextureButton

const REGISTRY_KEY := "add_character_button"

const _Canvas := preload("res://addons/oasis_dialogue/canvas/canvas.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.gd")
const _Model := preload("res://addons/oasis_dialogue/model/model.gd")

signal character_added(name: String)

var _character_exists := Callable()
var _input_dialog_factory := Callable()


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	init_input_dialog_factory(
			registry.at(_Canvas.INPUT_DIALOG_FACTORY_REGISTRY_KEY)
	)

	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	init_character_exists(manager.character_exists)


func init_input_dialog_factory(callback: Callable) -> void:
	_input_dialog_factory = callback


func init_character_exists(callback: Callable) -> void:
	_character_exists = callback


func _ready() -> void:
	button_up.connect(_on_button_up)


func _on_button_up() -> void:
	var dialog: _InputDialog = _input_dialog_factory.call()
	dialog.set_placeholder_text("Enter character name...")
	dialog.set_validation(_validate)
	dialog.set_cancel_label("cancel")
	dialog.set_confirm_label("add")
	dialog.canceled.connect(_on_dialog_canceled.bind(dialog))
	dialog.confirmed.connect(_on_dialog_confirmed.bind(dialog))


func _on_dialog_canceled(dialog: Control) -> void:
	dialog.queue_free()
	dialog.get_parent().remove_child(dialog)


func _on_dialog_confirmed(character: String, dialog: Control) -> void:
	_on_dialog_canceled(dialog)
	character_added.emit(character)


func _validate(character: String) -> String:
	var message := ""
	if character == "":
		message = "Character cannot be a blank."
	elif _character_exists.call(character):
		message = "%s already exists." % character
	return message

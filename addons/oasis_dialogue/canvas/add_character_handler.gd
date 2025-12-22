@tool
extends Node

const REGISTRY_KEY := "add_character_handler"

const _Button := preload("res://addons/oasis_dialogue/canvas/add_character_button.gd")
const _Canvas := preload("res://addons/oasis_dialogue/canvas/canvas.gd")
const _CharacterMenu := preload("res://addons/oasis_dialogue/menu_bar/character.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.gd")

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

	var character_menu: _CharacterMenu = registry.at(_CharacterMenu.REGISTRY_KEY)
	character_menu.new_character_requested.connect(show_dialog)

	var button: _Button = registry.at(_Button.REGISTRY_KEY)
	button.button_up.connect(show_dialog)


func init_input_dialog_factory(callback: Callable) -> void:
	_input_dialog_factory = callback


func init_character_exists(callback: Callable) -> void:
	_character_exists = callback


func show_dialog() -> void:
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

@tool
extends Node

const REGISTRY_KEY := "remove_character_handler"

const _Canvas := preload("res://addons/oasis_dialogue/canvas/canvas.gd")
const _CharacterTree := preload("res://addons/oasis_dialogue/canvas/character_tree.gd")
const _InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

signal character_renamed(name: String)

## [code]func() -> String[/code]
var _get_active_character := Callable()
## [code]func() -> InputDialog[/code]
var _input_dialog_factory := Callable()
## [code]func(name: String) -> bool[/code]
var _can_rename_to := Callable()


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	init_get_active_character(manager.get_active_character)
	init_input_dialog_factory(registry.at(_Canvas.INPUT_DIALOG_FACTORY_REGISTRY_KEY))
	init_can_rename_to(manager.can_rename_active_to)

	var tree: _CharacterTree = registry.at(_CharacterTree.REGISTRY_KEY)
	tree.character_activated.connect(rename)


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

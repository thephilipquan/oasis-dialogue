@tool
extends Node

const REGISTRY_KEY := "remove_character_handler"

const _Canvas := preload("res://addons/oasis_dialogue/canvas/canvas.gd")
const _CharacterMenu := preload("res://addons/oasis_dialogue/menu_bar/character.gd")
const _ConfirmDialog := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.gd")
const _Graph := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

signal character_removed

var _get_branch_count := Callable()
var _get_active_character := Callable()
var _confirm_dialog_factory := Callable()


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	init_get_active_character(manager.get_active_character)

	var graph: _Graph = registry.at(_Graph.REGISTRY_KEY)
	init_get_branch_count(graph.get_branch_count)

	init_confirm_dialog_factory(
			registry.at(_Canvas.CONFIRM_DIALOG_FACTORY_REGISTRY_KEY)
	)

	var menu: _CharacterMenu = registry.at(_CharacterMenu.REGISTRY_KEY)
	menu.remove_requested.connect(remove)


func init_get_branch_count(callback: Callable) -> void:
	_get_branch_count = callback


func init_get_active_character(callback: Callable) -> void:
	_get_active_character = callback


func init_confirm_dialog_factory(callback: Callable) -> void:
	_confirm_dialog_factory = callback


func remove() -> void:
	if _get_branch_count.call() > 0:
		var dialog: _ConfirmDialog = _confirm_dialog_factory.call()
		var character: String = _get_active_character.call()
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

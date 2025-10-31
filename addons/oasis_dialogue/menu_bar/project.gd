@tool
extends PopupMenu

const REGISTRY_KEY := "project_menu"

const _AddCharacter := preload("res://addons/oasis_dialogue/canvas/add_character_handler.gd")
const _CharacterTree := preload("res://addons/oasis_dialogue/canvas/character_tree.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _RemoveCharacter := preload("res://addons/oasis_dialogue/canvas/remove_character_handler.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

signal save_requested
signal export_requested

enum Item {
	SAVE = 0,
	EXPORT = 1,
}

var _get_character_count := Callable()


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	set_items()
	id_pressed.connect(emit_item_signal)


func set_items() -> void:
	var i := InputEventKey.new()

	i.ctrl_pressed = true
	i.shift_pressed = true
	i.keycode = KEY_S
	add_item("Save", Item.SAVE, i.get_keycode_with_modifiers())
	add_item("Export", Item.EXPORT)


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var tree: _CharacterTree = registry.at(_CharacterTree.REGISTRY_KEY)
	init_get_character_count(tree.get_item_count)

	var add_character: _AddCharacter = registry.at(_AddCharacter.REGISTRY_KEY)
	add_character.character_added.connect(update_item_states.unbind(1), CONNECT_DEFERRED)

	var remove_character: _RemoveCharacter = registry.at(_RemoveCharacter.REGISTRY_KEY)
	remove_character.character_removed.connect(update_item_states, CONNECT_DEFERRED)

	var project_manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	project_manager.project_loaded.connect(update_item_states, CONNECT_DEFERRED)


func init_get_character_count(callback: Callable) -> void:
	_get_character_count = callback


func update_item_states() -> void:
	var character_count: int = _get_character_count.call()
	if character_count == 0:
		set_item_disabled(Item.EXPORT, true)
	else:
		set_item_disabled(Item.EXPORT, false)


func emit_item_signal(id: int) -> void:
	var signals: Array[Signal] = [
			save_requested,
			export_requested,
	]
	signals[id].emit()

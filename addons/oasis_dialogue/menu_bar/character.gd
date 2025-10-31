@tool
extends PopupMenu

const REGISTRY_KEY := "character_menu"

const _AddCharacter := preload("res://addons/oasis_dialogue/canvas/add_character_handler.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _RemoveCharacter := preload("res://addons/oasis_dialogue/canvas/remove_character_handler.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

signal new_character_requested
signal save_requested
signal rename_requested
signal remove_requested

enum Item {
	NEW,
	SAVE,
	RENAME,
	# Separator here consumes an id.
	REMOVE = RENAME + 2,
}

var _get_active_character := Callable()


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	set_items()
	id_pressed.connect(emit_item_signal)


func set_items() -> void:
	var i := InputEventKey.new()

	i.ctrl_pressed = true
	i.keycode = KEY_N
	add_item("New...", Item.NEW, i.get_keycode_with_modifiers())

	i = InputEventKey.new()
	i.ctrl_pressed = true
	i.keycode = KEY_S
	add_item("Save", Item.SAVE, i.get_keycode_with_modifiers())

	add_item("Rename", Item.RENAME)

	add_separator()
	add_item("Delete", Item.REMOVE)


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var project_manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	init_get_active_character(project_manager.get_active_character)

	var add_character: _AddCharacter = registry.at(_AddCharacter.REGISTRY_KEY)
	add_character.character_added.connect(update_item_states.unbind(1), CONNECT_DEFERRED)

	var remove_character: _RemoveCharacter = registry.at(_RemoveCharacter.REGISTRY_KEY)
	remove_character.character_removed.connect(update_item_states, CONNECT_DEFERRED)

	project_manager.project_loaded.connect(update_item_states, CONNECT_DEFERRED)
	project_manager.character_loaded.connect(update_item_states.unbind(1), CONNECT_DEFERRED)


func init_get_active_character(callback: Callable) -> void:
	_get_active_character = callback


func update_item_states() -> void:
	const items: Array[Item] = [
			Item.SAVE,
			Item.RENAME,
			Item.REMOVE,
	]
	var active_character: String = _get_active_character.call()
	var callback := Callable()
	if active_character:
		callback = set_item_disabled.bind(false)
	else:
		callback = set_item_disabled.bind(true)
	items.map(callback)


func emit_item_signal(id: int) -> void:
	var s := Signal()
	match id:
		Item.NEW:
			s = new_character_requested
		Item.SAVE:
			s = save_requested
		Item.RENAME:
			s = rename_requested
		Item.REMOVE:
			s = remove_requested
	s.emit()

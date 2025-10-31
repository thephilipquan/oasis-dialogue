@tool
extends PopupMenu

const REGISTRY_KEY := "character_menu"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

signal new_character_requested
signal save_requested
signal rename_requested
signal remove_requested


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	set_items()
	id_pressed.connect(emit_item_signal)


func set_items() -> void:
	var i := InputEventKey.new()

	i.ctrl_pressed = true
	i.keycode = KEY_N
	add_item("New...", -1, i.get_keycode_with_modifiers())

	i = InputEventKey.new()
	i.ctrl_pressed = true
	i.keycode = KEY_S
	add_item("Save", -1, i.get_keycode_with_modifiers())

	add_item("Rename")

	add_separator()
	add_item("Delete")


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func emit_item_signal(id: int) -> void:
	var signals: Array[Signal] = [
			new_character_requested,
			save_requested,
			rename_requested,
			Signal(), # Separator.
			remove_requested,
	]
	signals[id].emit()

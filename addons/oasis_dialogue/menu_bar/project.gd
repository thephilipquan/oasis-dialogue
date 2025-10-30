@tool
extends PopupMenu

const REGISTRY_KEY := "project_menu"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

signal save_requested
signal export_requested


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
	add_item("Save", -1, i.get_keycode_with_modifiers())
	add_item("Export")


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func emit_item_signal(id: int) -> void:
	var signals: Array[Signal] = [
			save_requested,
			export_requested,
	]
	signals[id].emit()

@tool
extends PopupMenu

const REGISTRY_KEY := "help_menu"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

signal view_documentation_requested
signal report_bug_requested

enum Item {
	DOCUMENTATION,
	REPORT_BUG,
}


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	set_items()
	id_pressed.connect(emit_item_signal)


func set_items() -> void:
	add_item("How to Write", Item.DOCUMENTATION)
	add_item("Report a Bug", Item.REPORT_BUG)


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func emit_item_signal(id: int) -> void:
	var s := Signal()
	match id:
		Item.DOCUMENTATION:
			s = view_documentation_requested
		Item.REPORT_BUG:
			s = report_bug_requested
	s.emit()

@tool
extends Tree

const REGISTRY_KEY := "character_tree"

const _Graph := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _RenameCharacterHandler := preload("res://addons/oasis_dialogue/canvas/rename_character_handler.gd")
const _AddCharacterHandler := preload("res://addons/oasis_dialogue/canvas/add_character_handler.gd")
const _RemoveCharacterHandler := preload("res://addons/oasis_dialogue/canvas/remove_character_handler.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Save := preload("res://addons/oasis_dialogue/save.gd")

signal item_rename_requested
# [signal item_selected] is already defined in base so "character".
signal character_selected(name: String)
signal changed

const _DIRTY_SYMBOL := " *"


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var rename_character_handler: _RenameCharacterHandler = (
		registry.at(_RenameCharacterHandler.REGISTRY_KEY)
	)
	rename_character_handler.character_renamed.connect(edit_selected_item)

	var add_character: _AddCharacterHandler = registry.at(_AddCharacterHandler.REGISTRY_KEY)
	add_character.character_added.connect(add_and_select_item)

	var remove_character: _RemoveCharacterHandler = registry.at(_RemoveCharacterHandler.REGISTRY_KEY)
	remove_character.character_removed.connect(remove_selected_item)

	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	manager.settings_loaded.connect(load_settings)
	manager.character_saved.connect(unmark_dirty)

	var graph: _Graph = registry.at(_Graph.REGISTRY_KEY)
	graph.dirtied.connect(mark_selected_item_dirty)


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	add_item("root")
	item_selected.connect(_on_item_selected)
	item_activated.connect(_on_item_activated)


func add_item(text: String) -> TreeItem:
	var item := create_item()
	item.set_text(0, text)
	changed.emit()
	return item


func select_item(item: TreeItem) -> void:
	item.select(0)


func add_and_select_item(text: String) -> void:
	var item := add_item(text)
	select_item(item)


func remove_selected_item() -> void:
	get_selected().free()
	changed.emit()


func get_item_count() -> int:
	return get_root().get_child_count()


func get_selected_item() -> String:
	var text := ""
	var selected := get_selected()
	if selected:
		text = selected.get_text(0)
	return text


func edit_selected_item(to: String) -> void:
	var item := get_selected()
	item.set_text(0, to)
	changed.emit()


func mark_selected_item_dirty() -> void:
	var text := get_selected_item()
	if _is_dirty(text):
		return
	text = _dirty_text(text)
	edit_selected_item(text)


func unmark_dirty(character: String) -> void:
	var text := _dirty_text(character)
	var item := find_item(text)
	if not item:
		push_warning("couldn't find item (%s) to undirty" % character)
		return
	item.set_text(0, character)
	changed.emit()


func set_items(items: Array[String]) -> void:
	get_root().get_children().map(func(t: TreeItem) -> void: t.free())
	for item in items:
		add_item(item)


func find_item(value: String) -> TreeItem:
	for child in get_root().get_children():
		if child.get_text(0) == value:
			return child
	return null


func get_longest_item() -> String:
	var longest := ""
	var n := 0
	for item in get_root().get_children():
		var text := item.get_text(0)
		var m := text.length()
		if m > n:
			n = m
			longest = text
	return longest


func load_settings(data: ConfigFile) -> void:
	var characters: Array[String] = []
	characters.assign(data.get_value(_Save.Project.CHARACTERS, _Save.DUMMY, []))
	set_items(characters)

	var active_item: String = data.get_value(
			_Save.Project.SESSION,
			_Save.Project.Session.ACTIVE,
			""
	)
	if active_item:
		var item := find_item(active_item)
		if item:
			select_item(item)
		else:
			push_warning("active (%s) not found in character tree" % active_item)
	changed.emit()


func _on_item_selected() -> void:
	var character := get_selected_item()
	character = _clean_text(character)
	character_selected.emit(character)


func _on_item_activated() -> void:
	item_rename_requested.emit()


func _dirty_text(text: String) -> String:
	return "%s%s" % [text, _DIRTY_SYMBOL]


func _clean_text(text: String) -> String:
	return text.rstrip(_DIRTY_SYMBOL)


func _is_dirty(text: String) -> bool:
	return text.ends_with(_DIRTY_SYMBOL)

@tool
extends Tree

const REGISTRY_KEY := "character_tree"

const _Graph := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _RenameCharacterHandler := preload("res://addons/oasis_dialogue/canvas/rename_character_handler.gd")
const _AddCharacter := preload("res://addons/oasis_dialogue/canvas/add_character_button.gd")
const _RemoveCharacter := preload("res://addons/oasis_dialogue/canvas/remove_character_button.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Save := preload("res://addons/oasis_dialogue/save.gd")

signal character_activated()
signal character_selected(name: String)

const _DIRTY_SYMBOL := " *"


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var rename_character_handler: _RenameCharacterHandler = (
		registry.at(_RenameCharacterHandler.REGISTRY_KEY)
	)
	rename_character_handler.character_renamed.connect(edit_selected_item)

	var add_character: _AddCharacter = registry.at(_AddCharacter.REGISTRY_KEY)
	add_character.character_added.connect(add_item)

	var remove_character: _RemoveCharacter = registry.at(_RemoveCharacter.REGISTRY_KEY)
	remove_character.character_removed.connect(remove_selected_item)

	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	manager.settings_loaded.connect(load_settings)
	manager.character_saved.connect(unmark_dirty)

	var graph: _Graph = registry.at(_Graph.REGISTRY_KEY)
	graph.dirtied.connect(mark_active_dirty)


func _ready() -> void:
	add_item("root")
	item_selected.connect(_on_item_selected)
	item_activated.connect(_on_item_activated)


func add_item(text: String) -> void:
	var item := create_item()
	item.set_text(0, text)


func select_item(item: TreeItem) -> void:
	item.select(0)


func remove_selected_item() -> void:
	get_selected().free()


func get_selected_item() -> String:
	var text := ""
	var selected := get_selected()
	if selected:
		text = selected.get_text(0)
	return text


func edit_selected_item(to: String) -> void:
	var item := get_selected()
	item.set_text(0, to)


func mark_active_dirty() -> void:
	var text := get_selected_item()
	if _is_dirty(text):
		return
	text = _dirty_text(text)
	edit_selected_item(text)


func unmark_dirty(name: String) -> void:
	var text := _dirty_text(name)
	var item := find_item(text)
	if not item:
		push_warning("couldn't find item (%s) to undirty" % name)
		return
	item.set_text(0, name)


func set_items(items: Array[String]) -> void:
	get_root().get_children().map(func(t: TreeItem): t.free())
	for item in items:
		add_item(item)


func find_item(value: String) -> TreeItem:
	for child in get_root().get_children():
		if child.get_text(0) == value:
			return child
	return null


func load_settings(data: ConfigFile) -> void:
	var characters: Array[String] = []
	characters.assign(data.get_value(_Save.Project.CHARACTERS, _Save.DUMMY, []))
	set_items(characters)

	var name: String = data.get_value(
			_Save.Project.SESSION,
			_Save.Project.Session.ACTIVE,
			""
	)
	if name:
		var item := find_item(name)
		if item:
			select_item(item)
		else:
			push_warning("active (%s) not found in character tree" % name)


func _on_item_selected() -> void:
	var name := get_selected_item()
	name = _clean_text(name)
	character_selected.emit(name)


func _on_item_activated():
	character_activated.emit()


func _dirty_text(text: String) -> String:
	return "%s%s" % [text, _DIRTY_SYMBOL]


func _clean_text(text: String) -> String:
	return text.rstrip(_DIRTY_SYMBOL)


func _is_dirty(text: String) -> bool:
	return text.ends_with(_DIRTY_SYMBOL)


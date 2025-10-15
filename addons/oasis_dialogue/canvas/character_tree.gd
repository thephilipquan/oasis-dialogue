@tool
extends Tree

const REGISTRY_KEY := "character_tree"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _RenameCharacterHandler := preload("res://addons/oasis_dialogue/canvas/rename_character_handler.gd")
const _AddCharacter := preload("res://addons/oasis_dialogue/canvas/add_character_button.gd")
const _RemoveCharacter := preload("res://addons/oasis_dialogue/canvas/remove_character_button.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Global := preload("res://addons/oasis_dialogue/global.gd")
const _JsonUtils := preload("res://addons/oasis_dialogue/utils/json_utils.gd")

signal character_activated()
signal character_selected(name: String)


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
	manager.project_loaded.connect(load_project)


func _ready() -> void:
	add_item("root")
	item_selected.connect(_on_item_selected)
	item_activated.connect(_on_item_activated)


func add_item(text: String) -> void:
	var item := create_item()
	item.set_text(0, text)


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


func set_items(items: Array[String]) -> void:
	get_root().get_children().map(func(t: TreeItem): t.free())
	for item in items:
		add_item(item)


func load_project(data: Dictionary) -> void:
	for child in get_root().get_children():
		child.free()
	var characters: Array[String] = []
	characters.assign(data.get(_Global.PROJECT_CHARACTERS, []))

	for name in characters:
		add_item(name)

	var name: String = _JsonUtils.safe_get(data, _Global.PROJECT_ACTIVE, "")
	if name:
		for child in get_root().get_children():
			if child.get_text(0) == name:
				child.select(0)


func _on_item_selected() -> void:
	character_selected.emit(get_selected_item())


func _on_item_activated():
	character_activated.emit()

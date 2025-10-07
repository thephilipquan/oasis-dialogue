@tool
extends Tree

const _Global := preload("res://addons/oasis_dialogue/global.gd")
const _JsonUtils := preload("res://addons/oasis_dialogue/utils/json_utils.gd")

signal character_activated()
signal character_selected(name: String)


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
	characters.assign(data.get(_Global.LOAD_PROJECT_CHARACTERS, []))

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

extends GraphEdit

const _DIALOGUE_NODE := preload("res://addons/oasis_dialogue/dialogue_node/dialogue_node.tscn")

@onready
var _tree := $Tree as Tree
@onready
var _add_character := $AddCharacter as TextureButton

func _ready() -> void:
	scroll_offset = -size

	for c in get_children():
		if c is TextureButton:
			c.reparent(get_menu_hbox())

	var item := _tree.create_item()
	item.set_text(0, "root")


func _on_add() -> void:
	var node: GraphNode = _DIALOGUE_NODE.instantiate()
	node.position_offset = (size / 2 + scroll_offset) / zoom - node.size / 2
	add_child(node)


func _on_add_character_button_up() -> void:
	var item := _tree.create_item()
	item.set_text(0, "")
	item.set_editable(0, true)
	_tree.edit_selected()


func _on_tree_item_activated() -> void:
	var item := _tree.get_selected()
	assert(item)
	item.set_editable(0, true)
	_tree.edit_selected()


func _on_tree_item_edited() -> void:
	var item := _tree.get_selected()
	assert(item)
	item.set_editable(0, false)

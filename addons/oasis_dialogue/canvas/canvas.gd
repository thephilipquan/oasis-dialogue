@tool
extends Control

const _DIALOGUE_NODE := preload("res://addons/oasis_dialogue/dialogue_branch/dialogue_branch.tscn")

@onready
var _tree: Tree = %Tree
@onready
var _graph_edit: GraphEdit = %GraphEdit


func _ready() -> void:
	_graph_edit.scroll_offset = -size

	var item := _tree.create_item()
	item.set_text(0, "root")

	%AddCharacter.button_up.connect(_on_add_character_button_up)
	%AddDialogue.button_up.connect(_on_add)


func _on_add() -> void:
	var node: GraphNode = _DIALOGUE_NODE.instantiate()
	node.position_offset = (_graph_edit.size / 2 + _graph_edit.scroll_offset) / _graph_edit.zoom - node.size / 2
	_graph_edit.add_child(node)


func _on_add_character_button_up() -> void:
	var item := _tree.create_item()
	item.set_text(0, "")
	item.set_editable(0, true)
	#_tree.edit_selected()


func _on_tree_item_activated() -> void:
	var item := _tree.get_selected()
	assert(item)
	item.set_editable(0, true)
	_tree.edit_selected()


func _on_tree_item_edited() -> void:
	var item := _tree.get_selected()
	assert(item)
	item.set_editable(0, false)

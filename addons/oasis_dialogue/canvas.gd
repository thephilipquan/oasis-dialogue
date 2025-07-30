extends GraphEdit

#@onready
#var _add := $HBoxContainer/Add as Button

const _DIALOGUE_NODE := preload("res://addons/oasis_dialogue/dialogue_node.tscn")

func _ready() -> void:
	scroll_offset = -size
	var add := Button.new()
	add.text = "add"
	add.pressed.connect(_on_add)
	get_menu_hbox().add_child(add)


func _on_add() -> void:
	var node: GraphNode = _DIALOGUE_NODE.instantiate()
	node.position_offset = (size / 2 + scroll_offset) / zoom - node.size / 2
	add_child(node)

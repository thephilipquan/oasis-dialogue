@tool
class_name DialogueNode
extends GraphNode


func _ready() -> void:
	var title_hbox := get_titlebar_hbox()
	var label: Label = title_hbox.get_children()[0]
	title_hbox.remove_child(label)


func _unhandled_key_input(event: InputEvent) -> void:
	if selected and Input.is_key_pressed(KEY_X):
		queue_free()

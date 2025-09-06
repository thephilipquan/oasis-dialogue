class_name DialogueNode
extends GraphNode


func _ready() -> void:
	var title_hbox := get_titlebar_hbox()
	var label: Label = title_hbox.get_children()[0]
	label.text = "3"

	#var text_edit := TextEdit.new()
	#title_hbox.add_child(text_edit)


func _unhandled_key_input(event: InputEvent) -> void:
	if selected and event.is_action_pressed("delete_node"):
		queue_free()

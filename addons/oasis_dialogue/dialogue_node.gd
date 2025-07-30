class_name DialogueNode
extends GraphNode


func _unhandled_key_input(event: InputEvent) -> void:
	if selected and event.is_action_pressed("delete_node"):
		print("deleting")
		queue_free()

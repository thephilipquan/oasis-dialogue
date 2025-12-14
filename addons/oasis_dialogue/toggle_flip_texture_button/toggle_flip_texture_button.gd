@tool
extends TextureButton

func _ready() -> void:
	if is_part_of_edited_scene():
		return

	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	flip_h = not flip_h

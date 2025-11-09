@tool
extends Label


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	text = ProjectSettings.get_setting("application/config/version")

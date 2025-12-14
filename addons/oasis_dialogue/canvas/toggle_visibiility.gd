@tool
extends Node

@export
var button: BaseButton = null
@export
var target: CanvasItem = null


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	button.pressed.connect(toggle_visibility)


func toggle_visibility() -> void:
	target.visible = not target.visible

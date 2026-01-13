## A control that listens to when and where the target was double clicked.
@tool
extends Control

signal double_clicked_at(position: Vector2)

@export
var target: Control = null


func _ready() -> void:
	target.gui_input.connect(_on_target_gui_input)


func _on_target_gui_input(event: InputEvent) -> void:
	var cast := event as InputEventMouseButton
	if not cast:
		return
	if cast.double_click:
		double_clicked_at.emit(cast.position)

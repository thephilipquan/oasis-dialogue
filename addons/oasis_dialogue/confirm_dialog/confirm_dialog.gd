@tool
extends Control

signal confirmed
signal canceled

@onready
var _message: Label = $CenterContainer/VBoxContainer/Message


func set_message(text: String) -> void:
	_message.text = text


func set_cancel_label(text: String) -> void:
	var button: Button = $CenterContainer/VBoxContainer/HBoxContainer/Cancel
	button.text = text


func set_confirm_label(text: String) -> void:
	var button: Button = $CenterContainer/VBoxContainer/HBoxContainer/Confirm
	button.text = text


func _on_cancel_button_up() -> void:
	canceled.emit()


func _on_confirm_button_up() -> void:
	confirmed.emit()

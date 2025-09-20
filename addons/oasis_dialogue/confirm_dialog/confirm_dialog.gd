@tool
extends Control

var _on_cancel := Callable()
var _on_confirm := Callable()

@onready
var _message: Label = $CenterContainer/VBoxContainer/Message


func set_message(text: String) -> void:
	_message.text = text


func set_on_cancel(label: String, on_cancel: Callable) -> void:
	var button: Button = $CenterContainer/VBoxContainer/HBoxContainer/Cancel
	button.text = label
	_on_cancel = on_cancel


func set_on_confirm(label: String, on_confirm: Callable) -> void:
	var button: Button = $CenterContainer/VBoxContainer/HBoxContainer/Confirm
	button.text = label
	_on_confirm = on_confirm


func _on_cancel_button_up() -> void:
	_on_cancel.call()


func _on_confirm_button_up() -> void:
	_on_confirm.call()

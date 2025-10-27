@tool
extends Control

signal confirmed(text: String)
signal canceled

const ILLEGAL_CHARS := " <>:\"/\\|?*"

var _validate := Callable()

@onready
var _line_edit: LineEdit = $CenterContainer/VBoxContainer/LineEdit


func _ready() -> void:
	_line_edit.grab_focus()


func set_placeholder_text(text: String) -> void:
	_line_edit.placeholder_text = text


func set_validation(validate: Callable) -> void:
	_validate = validate


func set_cancel_label(text: String) -> void:
	var button: Button = $CenterContainer/VBoxContainer/HBoxContainer/Cancel
	button.text = text


func set_confirm_label(text: String) -> void:
	var button: Button = $CenterContainer/VBoxContainer/HBoxContainer/Confirm
	button.text = text


func _on_confirm_button_up() -> void:
	_confirm()


func _on_line_edit_text_submitted(_new_text: String) -> void:
	_confirm()


func _confirm() -> void:
	var character := _line_edit.text
	var status: String = _validate.call(character)
	if status:
		return
	confirmed.emit(character)


func _on_line_edit_text_changed(new_text: String) -> void:
	new_text = new_text.remove_chars(ILLEGAL_CHARS)
	var before := _line_edit.caret_column

	_line_edit.text = new_text
	_line_edit.caret_column = before

	var status: String = _validate.call(new_text)
	_update_status(status)


func _update_status(message: String) -> void:
	var label: Label = $CenterContainer/VBoxContainer/Status
	label.text = message
	if not message:
		label.hide()
	else:
		label.show()


func _on_cancel_button_up() -> void:
	canceled.emit()

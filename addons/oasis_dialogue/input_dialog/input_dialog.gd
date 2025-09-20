@tool
extends Control


var _validate := Callable()
var _on_done := Callable()
var _on_cancel := Callable()

@onready
var _line_edit: LineEdit = $CenterContainer/VBoxContainer/LineEdit


func _ready() -> void:
	_line_edit.grab_focus()


func set_placeholder_text(text: String) -> void:
	_line_edit.placeholder_text = text


func set_on_done(on_done: Callable) -> void:
	_on_done = on_done


func set_validation(validate: Callable) -> void:
	_validate = validate


func set_on_cancel(on_cancel: Callable) -> void:
	_on_cancel = on_cancel


func _on_done_button_up() -> void:
	_done()


func _on_line_edit_text_submitted(new_text: String) -> void:
	_done()


func _done() -> void:
	var name := _line_edit.text
	var status := _validate.call(name)
	if status:
		return
	_on_done.call(name)


func _on_line_edit_text_changed(new_text: String) -> void:
	var before := _line_edit.caret_column
	_line_edit.text = new_text.replace(" ", "")
	_line_edit.caret_column = before
	var status := _validate.call(new_text)
	_update_status(status)


func _update_status(message: String) -> void:
	var label: Label = $CenterContainer/VBoxContainer/Status
	label.text = message
	if not message:
		label.hide()
	else:
		label.show()


func _on_cancel_button_up() -> void:
	_on_cancel.call()

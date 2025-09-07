@tool
class_name ToggleButton
extends HBoxContainer

signal toggled(value)

@export
var left_label := "":
	set(value):
		left_label = value
		if Engine.is_editor_hint():
			_left_label.text = left_label
@export
var right_label := "":
	set(value):
		right_label = value
		if Engine.is_editor_hint():
			_right_label.text = right_label
@export
var value := false:
	set(new_value):
		value = new_value
		if Engine.is_editor_hint():
			_button.button_pressed = value

@onready
var _left_label: Label = $LeftLabel
@onready
var _button := $CheckButton as CheckButton
@onready
var _right_label: Label = $RightLabel


func _ready() -> void:
	_left_label.text = left_label
	_button.button_pressed = value
	_right_label.text = right_label


func _toggled(value: bool) -> void:
	toggled.emit(value)

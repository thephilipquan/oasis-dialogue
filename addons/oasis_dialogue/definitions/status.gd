@tool
extends PanelContainer

const _Error := preload("res://addons/oasis_dialogue/definitions/model/error.gd")

@onready
var _text: Label = $Label


func err(error: _Error) -> void:
	var text := ""

	if _text.text != "":
		text += "\n"

	text += error.message

	_text.text += text


func clear() -> void:
	_text.text = ""

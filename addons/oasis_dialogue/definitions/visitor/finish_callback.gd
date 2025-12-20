extends "res://addons/oasis_dialogue/definitions/visitor/visitor.gd"

var _callback := Callable()


func _init(callback: Callable) -> void:
	_callback = callback


func finish() -> void:
	_callback.call()

@tool
extends Node

var _map := {}


func _ready() -> void:
	get_tree().call_group("registerable", "register", self)
	get_tree().call_group("registerable", "setup", self)


func add(key: String, instance) -> void:
	assert(not key in _map)
	_map[key] = instance


func at(key: String):
	assert(key in _map)
	return _map[key]

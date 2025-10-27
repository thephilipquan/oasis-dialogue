@tool
extends Node

var _map := {}


func _ready() -> void:
	get_tree().call_group("registerable", "register", self)
	get_tree().call_group("registerable", "setup", self)


func add(key: String, instance: Variant) -> void:
	assert(not key in _map)
	_map[key] = instance


func at(key: String) -> Variant:
	assert(key in _map)
	return _map[key]

@tool
extends Node

const GROUP := "oasis_registerable"

var _map := {}


func trigger() -> void:
	_map.clear()
	get_tree().call_group(GROUP, "register", self)
	get_tree().call_group(GROUP, "setup", self)


func has(key: String) -> bool:
	return key in _map


func add(key: String, instance: Variant) -> void:
	assert(not key in _map)
	_map[key] = instance


func at(key: String) -> Variant:
	assert(key in _map)
	return _map[key]

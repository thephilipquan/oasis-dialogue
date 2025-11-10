@tool
extends Node

const GROUP := &"oasis_registerable"

const _NodeUtils := preload("res://addons/oasis_dialogue/utils/node_utils.gd")

var _map := {}


func trigger() -> void:
	_map.clear()

	# This is necessary if the user has a group with the same name.
	_NodeUtils.call_group_under_parent(get_parent(), GROUP, &"register", self)
	_NodeUtils.call_group_under_parent(get_parent(), GROUP, &"setup", self)


func has(key: String) -> bool:
	return key in _map


func add(key: String, instance: Variant) -> void:
	assert(not key in _map)
	_map[key] = instance


func at(key: String) -> Variant:
	assert(key in _map)
	return _map[key]

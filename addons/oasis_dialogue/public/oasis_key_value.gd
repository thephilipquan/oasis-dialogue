class_name OasisKeyValue
extends RefCounted

const _JsonVisitor := preload("res://addons/oasis_dialogue/visitor/json_visitor.gd")

var key := ""
var value := -1

func _init(key: String, value := -1) -> void:
	self.key = key
	self.value = value


static func from_jsons(jsons: Array) -> Array[OasisKeyValue]:
	var key_values: Array[OasisKeyValue] = []
	for json: Dictionary in jsons:
		var kv := new(
				json[_JsonVisitor.KEY_VALUE_LEFT],
				json.get(_JsonVisitor.KEY_VALUE_RIGHT, -1),
		)
		key_values.push_back(kv)
	return key_values

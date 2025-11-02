## A key value pair that represents the name of the condition/action as notated
## by the dialogue writer, along with an optional value that, if described by
## the writer, serves as the argument to the condition/action.
class_name OasisKeyValue
extends RefCounted

const _JsonVisitor := preload("res://addons/oasis_dialogue/visitor/json_visitor.gd")

## The name of the conditon/action.
var key := ""
## The optional value of the condition/action.
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

class_name OasisLine
extends RefCounted

const _JsonVisitor := preload("res://addons/oasis_dialogue/visitor/json_visitor.gd")

var key := ""
var conditions: Array[OasisKeyValue] = []
var actions: Array[OasisKeyValue] = []


func _init(
		key: String,
		conditions: Array[OasisKeyValue] = [],
		actions: Array[OasisKeyValue] = [],
) -> void:
	self.key = key
	self.conditions = conditions
	self.actions = actions


static func from_jsons(jsons: Array) -> Array[OasisLine]:
	var lines: Array[OasisLine] = []
	for json: Dictionary in jsons:
		var line := new(
				json[_JsonVisitor.LINE_KEY],
				OasisKeyValue.from_jsons(
					json.get(_JsonVisitor.LINE_CONDITIONS, [])
				),
				OasisKeyValue.from_jsons(
					json.get(_JsonVisitor.LINE_ACTIONS, [])
				),
		)
		lines.push_back(line)
	return lines

class_name OasisBranch
extends RefCounted

const _JsonVisitor := preload("res://addons/oasis_dialogue/visitor/json_visitor.gd")

var id := -1
var annotations: Array[String] = []
var prompts: Array[OasisLine] = []
var responses: Array[OasisLine] = []


func _init(
		annotations: Array[String] = [],
		prompts: Array[OasisLine] = [],
		responses: Array[OasisLine] = [],
):
	self.annotations = annotations
	self.prompts = prompts
	self.responses = responses


func init_id(id: int) -> void:
	self.id = id


static func from_json(json: Dictionary) -> OasisBranch:
	var annotations: Array[String] = []
	annotations.assign(json.get(_JsonVisitor.BRANCH_ANNOTATIONS, []))

	return new(
			annotations,
			OasisLine.from_jsons(
					json.get(_JsonVisitor.BRANCH_PROMPTS, [])
			),
			OasisLine.from_jsons(
					json.get(_JsonVisitor.BRANCH_RESPONSES, [])
			),
	)

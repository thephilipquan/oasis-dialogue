## A branch of dialogue that contains prompts to be shown to the player and
## responses to be chosen by the player.
class_name OasisBranch
extends RefCounted

const _JsonVisitor := preload("res://addons/oasis_dialogue/visitor/json_visitor.gd")

## The branch's identifier.
var id := -1

## The annotations that control how this branch is handled and shown to the
## player.
var annotations: Array[String] = []

## The [OasisLine]s spoken by the character.
var prompts: Array[OasisLine] = []

## The [OasisLine]s shown to the player to choose from.
var responses: Array[OasisLine] = []


func _init(
		annotations: Array[String] = [],
		prompts: Array[OasisLine] = [],
		responses: Array[OasisLine] = [],
):
	self.annotations = annotations
	self.prompts = prompts
	self.responses = responses


## Must be called when initialized. Sets the branch's id.
##
## Used by [OasisManager].
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

extends RefCounted

const _Visitor := preload("res://addons/oasis_dialogue/visitor/visitor.gd")

class ASTNode:
	extends RefCounted

	func accept(visitor: _Visitor) -> void:
		pass

	func to_json() -> Dictionary:
		return {}

	func equals(other: ASTNode) -> bool:
		var cast := other as ASTNode
		return cast != null


#class Character:
	#extends ASTNode
#
	#var name := ""
	#var branches: Dictionary[int, Branch] = {}
#
	#func _init(name: String, branches: Dictionary[int, Branch]) -> void:
		#self.name = name
		#self.branches = branches
#
	#func accept(visitor: _Visitor) -> void:
		#branches.values().map(func(n: ASTNode): n.accept(visitor))
#
	#static func from_jsons(jsons: Array) -> Array[Character]:
		#var characters: Array[Character] = []
		#for json in jsons:
			#characters.push_back(from_json(json))
		#return characters
#
	#static func from_json(json: Dictionary) -> Character:
		#var branches: Dictionary[int, Branch] = {}
		#for branch in Branch.from_jsons(json["branches"]):
			#branches[branch.id] = branch
		#return new(
			#json["name"],
			#branches,
		#)
#
	#func to_json() -> Dictionary:
		#return {
			#"name": name,
			#"branches": branches.values().map(func(n: ASTNode): return n.to_json()),
		#}
#
	#func equals(other: ASTNode)-> bool:
		#var cast := other as Character
		#if not cast:
			#return false
		#if (
			#name != cast.name
			#or branches.size() != cast.branches.size()
		#):
			#return false
		#for i in branches.size():
			#if not branches[i].equals(cast.branches[i]):
				#return false
		#return true
#
	#func _to_string() -> String:
		#return JSON.stringify(to_json())


class Branch:
	extends ASTNode

	var id := -1
	var annotations: Array[Annotation] = []
	var prompts: Array[Prompt] = []
	var responses: Array[Response] = []

	func _init(id: int, annotations: Array[Annotation], prompts: Array[Prompt], responses: Array[Response]) -> void:
		self.id = id
		self.annotations = annotations
		self.prompts = prompts
		self.responses = responses

	func accept(visitor: _Visitor) -> void:
		visitor.visit_branch(self)
		annotations.map(func(n: ASTNode): n.accept(visitor))
		prompts.map(func(n: ASTNode): n.accept(visitor))
		responses.map(func(n: ASTNode): n.accept(visitor))

	static func from_jsons(jsons: Dictionary) -> Dictionary[int, Branch]:
		var branches: Dictionary[int, Branch] = {}
		for id in jsons:
			branches[id] = from_json(jsons[id])
		return branches

	static func from_json(json: Dictionary) -> Branch:
		return new(
			json["id"],
			Annotation.from_jsons(json["annotations"]),
			Prompt.from_jsons(json["prompts"]),
			Response.from_jsons(json["responses"]),
		)

	func to_json() -> Dictionary:
		return {
			"id": id,
			"annotations": annotations.map(func(n: ASTNode): return n.to_json()),
			"prompts": prompts.map(func(n: ASTNode): return n.to_json()),
			"responses": responses.map(func(n: ASTNode): return n.to_json()),
		}

	func equals(other: ASTNode) -> bool:
		var cast := other as Branch
		if not cast:
			return false
		if (
			annotations.size != cast.annotations.size
			or prompts.size != cast.prompts.size
			or responses.size != cast.responses.size
		):
			return false
		for i in annotations.size():
			if not annotations[i].equals(cast.annotations[i]):
				return false
		for i in prompts.size():
			if not prompts[i].equals(cast.prompts[i]):
				return false
		for i in responses.size():
			if not responses[i].equals(cast.responses[i]):
				return false
		return true

	func _to_string() -> String:
		return JSON.stringify(to_json())


class Annotation:
	extends ASTNode
	var name := ""
	var value: ASTNode = null

	func _init(name: String, value: ASTNode) -> void:
		self.name = name
		self.value = value

	func accept(visitor: _Visitor) -> void:
		visitor.visit_annotation(self)
		if value:
			value.accept(visitor)

	static func from_jsons(jsons: Array) -> Array[Annotation]:
		var annotations: Array[Annotation] = []
		for json in jsons:
			annotations.push_back(from_json(json))
		return annotations

	static func from_json(json: Dictionary) -> Annotation:
		return new(
			json["name"],
			json["value"],
		)

	func to_json() -> Dictionary:
		var map := {
			"name": name,
			"value": value.to_json() if value else null,
		}
		return map

	func equals(other: ASTNode) -> bool:
		var cast := other as Annotation
		if not cast:
			return false
		return (
			name == cast.name
			and (
					(value == null and cast.value == null)
					or value.equals(cast.value)
			)
		)

	func _to_string() -> String:
		return JSON.stringify(to_json())


class Prompt:
	extends ASTNode
	var conditions: Array[Condition] = []
	var text: ASTNode = null
	var actions: Array[Action] = []

	func _init(conditions: Array[Condition], text: StringLiteral, actions: Array[Action]) -> void:
		self.conditions = conditions
		self.text = text
		self.actions = actions

	func accept(visitor: _Visitor) -> void:
		visitor.visit_prompt(self)
		conditions.map(func(n: ASTNode): n.accept(visitor))
		text.accept(visitor)
		actions.map(func(n: ASTNode): n.accept(visitor))

	static func from_jsons(jsons: Array) -> Array[Prompt]:
		var prompts: Array[Prompt] = []
		for json in jsons:
			prompts.push_back(from_json(json))
		return prompts

	static func from_json(json: Dictionary) -> Prompt:
		return new(
			Condition.from_jsons(json["conditions"]),
			StringLiteral.from_json(json["text"]),
			Action.from_jsons(json["actions"]),
		)

	func to_json() -> Dictionary:
		return {
			"conditions": conditions.map(func(n: ASTNode): return n.to_json()),
			"text": text.to_json(),
			"actions": actions.map(func(n: ASTNode): return n.to_json()),
		}

	func equals(other: ASTNode) -> bool:
		var cast := other as Prompt
		if not cast:
			return false
		if (
			conditions.size() != cast.conditions.size()
			or actions.size() != cast.actions.size()
		):
			return false
		for i in conditions.size():
			if not conditions[i].equals(cast.conditions[i]):
				return false
		for i in actions.size():
			if not actions[i].equals(cast.actions[i]):
				return false
		return (
			(text == null and cast.text == null)
			or text.equals(cast.text)
		)

	func _to_string() -> String:
		return JSON.stringify(to_json())


class Response:
	extends ASTNode
	var conditions: Array[Condition] = []
	var text: StringLiteral = null
	var actions: Array[Action] = []

	func _init(conditions: Array[Condition], text: StringLiteral, actions: Array[Action]) -> void:
		self.conditions = conditions
		self.text = text
		self.actions = actions

	func accept(visitor: _Visitor) -> void:
		visitor.visit_response(self)
		conditions.map(func(n: ASTNode): n.accept(visitor))
		text.accept(visitor)
		actions.map(func(n: ASTNode): n.accept(visitor))

	static func from_jsons(jsons: Array) -> Array[Response]:
		var responses: Array[Response] = []
		for json in jsons:
			responses.push_back(from_json(json))
		return responses

	static func from_json(json: Dictionary) -> Response:
		return new(
			Condition.from_jsons(json.get("conditions", [])),
			StringLiteral.from_json(json.get("text", [])),
			Action.from_jsons(json.get("actions", [])),
		)

	func to_json() -> Dictionary:
		return {
			"conditions": conditions.map(func(n: ASTNode): return n.to_json()),
			"text": text.to_json(),
			"actions": actions.map(func(n: ASTNode): return n.to_json()),
		}

	func equals(other: ASTNode) -> bool:
		var cast := other as Response
		if not cast:
			return false
		if (
			conditions.size() != cast.conditions.size()
			or actions.size() != cast.actions.size()
		):
			return false
		for i in conditions.size():
			if not conditions[i].equals(cast.conditions[i]):
				return false
		for i in actions.size():
			if not actions[i].equals(cast.actions[i]):
				return false
		return (
			(text == null and cast.text == null)
			or text.equals(cast.text)
		)

	func _to_string() -> String:
		return JSON.stringify(to_json())


class Condition:
	extends ASTNode
	var name := ""
	var value: NumberLiteral = null

	func _init(name: String, value: NumberLiteral) -> void:
		self.name = name
		self.value = value

	func accept(visitor: _Visitor) -> void:
		visitor.visit_condition(self)
		if value:
			value.accept(visitor)

	static func from_jsons(jsons: Array) -> Array[Condition]:
		var conditions: Array[Condition] = []
		for json in jsons:
			conditions.push_back(from_json(json))
		return conditions

	static func from_json(json: Dictionary) -> Condition:
		var value = json.get("value", null)
		if value:
			value = NumberLiteral.from_json(value)
		return new(
			json.get("name", ""),
			value,
		)

	func to_json() -> Dictionary:
		return {
			"name": name,
			"value": value.to_json() if value else null,
		}

	func equals(other: ASTNode) -> bool:
		var cast := other as Condition
		if not cast:
			return false
		return (
			name == cast.name
			and (
					(value == null and cast.value == null)
					or value.equals(cast.value)
			)
		)

	func _to_string() -> String:
		return JSON.stringify(to_json())


class Action:
	extends ASTNode
	var name := ""
	var value: NumberLiteral = null

	func _init(name: String, value: NumberLiteral) -> void:
		self.name = name
		self.value = value

	func accept(visitor: _Visitor) -> void:
		visitor.visit_action(self)
		if value:
			value.accept(visitor)

	static func from_jsons(jsons: Array) -> Array[Action]:
		var actions: Array[Action] = []
		for json in jsons:
			actions.push_back(from_json(json))
		return actions

	static func from_json(json: Dictionary) -> Action:
		var value = json.get("value", null)
		if value:
			value = NumberLiteral.from_json(value)
		return new(
			json.get("name", ""),
			value,
		)

	func to_json() -> Dictionary:
		return {
			"name": name,
			"value": value.to_json() if value else null,
		}

	func equals(other: ASTNode) -> bool:
		var cast := other as Action
		if not cast:
			return false
		return (
			name == cast.name
			and (
					(value == null and cast.value == null)
					or value.equals(cast.value)
			)
		)

	func _to_string() -> String:
		return JSON.stringify(to_json())


class StringLiteral:
	extends ASTNode
	var value := ""

	func _init(value: String) -> void:
		self.value = value

	func accept(visitor: _Visitor) -> void:
		visitor.visit_stringliteral(self)

	func to_json() -> Dictionary:
		return {
			"value": value,
		}

	static func from_json(json: Dictionary) -> StringLiteral:
		if not "value" in json:
			return null

		var value = json["value"]
		if not value is String:
			return null

		return new(value)

	func equals(other: ASTNode) -> bool:
		var cast := other as StringLiteral
		if not cast:
			return false
		return value == cast.value

	func _to_string() -> String:
		return JSON.stringify(to_json())


class NumberLiteral:
	extends ASTNode
	var value := 0

	func _init(value: int) -> void:
		self.value = value

	func accept(visitor: _Visitor) -> void:
		visitor.visit_numberliteral(self)

	static func from_json(json: Dictionary) -> NumberLiteral:
		if not "value" in json:
			return null

		var value = json["value"]
		if not (
			value is int
			or value is float
		):
			return null

		return new(value)

	func to_json() -> Dictionary:
		return {
			"value": value,
		}

	func equals(other: ASTNode) -> bool:
		var cast := other as NumberLiteral
		if not cast:
			return false
		return value == cast.value

	func _to_string() -> String:
		return JSON.stringify(to_json())

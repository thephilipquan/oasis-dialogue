extends RefCounted

const _Visitor := preload("res://addons/oasis_dialogue/visitor/visitor.gd")
const _type := preload("res://addons/oasis_dialogue/utils/json_utils.gd")

class ASTNode:
	extends RefCounted

	func _init(line: int, column: int) -> void:
		self.line = line
		self.column = column

	func accept(visitor: _Visitor) -> void:
		pass

	func to_json() -> Dictionary:
		return {}

	func equals(other: ASTNode) -> bool:
		var cast := other as ASTNode
		return cast != null


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

	static func from_jsons(jsons) -> Dictionary[int, Branch]:
		if not jsons is Dictionary:
			return {}

		var branches: Dictionary[int, Branch] = {}
		for key in jsons:
			if not _type.is_int(key):
				continue
			var id := _type.parse_int(key)
			var branch = from_json(jsons[key])
			if branch:
				branches[id] = branch
		return branches

	static func from_json(json) -> Branch:
		if not json is Dictionary:
			return null
		return new(
			json.get("id", -1),
			Annotation.from_jsons(json.get("annotations", [])),
			Prompt.from_jsons(json.get("prompts", [])),
			Response.from_jsons(json.get("responses", [])),
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
			id != other.id
			or annotations.size != cast.annotations.size
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

	var line := -1
	var column := -1
	var name := ""
	var value: ASTNode = null

	func _init(name: String, value: ASTNode, line := -1, column := -1) -> void:
		self.name = name
		self.value = value
		self.line = line
		self.column = column

	func accept(visitor: _Visitor) -> void:
		visitor.visit_annotation(self)
		if value:
			value.accept(visitor)

	static func from_jsons(jsons: Array) -> Array[Annotation]:
		if not jsons is Array:
			return []
		var annotations: Array[Annotation] = []
		for json in jsons:
			var annotation := from_json(json)
			if annotation:
				annotations.push_back(annotation)
		return annotations

	static func from_json(json) -> Annotation:
		if (
			not json is Dictionary
			or not "name" in json
			or not json["name"] is String
		):
			return null
		return new(
			json["name"],
			json.get("value", null),
			json.get("line", -1),
			json.get("column", -1),
		)

	func to_json() -> Dictionary:
		var map := {
			"name": name,
			"value": value.to_json() if value else null,
			"line": line,
			"column": column,
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

	static func from_jsons(jsons) -> Array[Prompt]:
		if not jsons is Array:
			return []
		var prompts: Array[Prompt] = []
		for json in jsons:
			var prompt := from_json(json)
			if prompt:
				prompts.push_back(prompt)
		return prompts

	static func from_json(json) -> Prompt:
		if not json is Dictionary:
			return null
		return new(
			Condition.from_jsons(json.get("conditions", [])),
			StringLiteral.from_json(json.get("text", {})),
			Action.from_jsons(json.get("actions", [])),
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

	static func from_jsons(jsons) -> Array[Response]:
		var responses: Array[Response] = []
		for json in jsons:
			responses.push_back(from_json(json))
		return responses

	static func from_json(json) -> Response:
		if not json is Dictionary:
			return null
		return new(
			Condition.from_jsons(json.get("conditions", [])),
			StringLiteral.from_json(json.get("text", {})),
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

	var line := -1
	var column := -1
	var name := ""
	var value: NumberLiteral = null

	func _init(name: String, value: NumberLiteral, line := -1, column := -1) -> void:
		self.name = name
		self.value = value
		self.line = line
		self.column = column

	func accept(visitor: _Visitor) -> void:
		visitor.visit_condition(self)
		if value:
			value.accept(visitor)

	static func from_jsons(jsons: Array) -> Array[Condition]:
		var conditions: Array[Condition] = []
		for json in jsons:
			conditions.push_back(from_json(json))
		return conditions

	static func from_json(json) -> Condition:
		var value = json.get("value", null)
		if value:
			value = NumberLiteral.from_json(value)
		return new(
			json.get("name", ""),
			value,
			json.get("line", -1),
			json.get("column", -1),
		)

	func to_json() -> Dictionary:
		return {
			"name": name,
			"value": value.to_json() if value else null,
			"line": line,
			"column": column,
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

	var line := -1
	var column := -1
	var name := ""
	var value: NumberLiteral = null

	func _init(name: String, value: NumberLiteral, line := -1, column := -1) -> void:
		self.name = name
		self.value = value
		self.line = line
		self.column = column

	func accept(visitor: _Visitor) -> void:
		visitor.visit_action(self)
		if value:
			value.accept(visitor)

	static func from_jsons(jsons: Array) -> Array[Action]:
		var actions: Array[Action] = []
		for json in jsons:
			actions.push_back(from_json(json))
		return actions

	static func from_json(json) -> Action:
		var value = json.get("value", null)
		if value:
			value = NumberLiteral.from_json(value)
		return new(
			json.get("name", ""),
			value,
			json.get("line", -1),
			json.get("column", -1),
		)

	func to_json() -> Dictionary:
		return {
			"name": name,
			"value": value.to_json() if value else null,
			"line": line,
			"column": column,
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

	var line := -1
	var column := -1
	var value := ""

	func _init(value: String, line := -1, column := -1) -> void:
		self.value = value
		self.line = line
		self.column = column

	func accept(visitor: _Visitor) -> void:
		visitor.visit_stringliteral(self)

	func to_json() -> Dictionary:
		return {
			"value": value,
			"line": line,
			"column": column,
		}

	static func from_json(json) -> StringLiteral:
		if not json is Dictionary:
			return null

		if not "value" in json:
			return null

		var value = json["value"]
		if not value is String:
			return null

		return new(
			value,
			json.get("line", -1),
			json.get("column", -1),
		)

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
	var line := -1
	var column := -1

	func _init(value: int, line := -1, column := -1) -> void:
		self.value = value
		self.line = line
		self.column = column

	func accept(visitor: _Visitor) -> void:
		visitor.visit_numberliteral(self)

	static func from_json(json) -> NumberLiteral:
		if (
			not json is Dictionary
			or not "value" in json
			or not _type.is_int(json["value"])
		):
			return null

		return new(
			_type.parse_int(json["value"]),
			json.get("line", -1),
			json.get("column", -1),
		)

	func to_json() -> Dictionary:
		return {
			"value": value,
			"line": line,
			"column": column,
		}

	func equals(other: ASTNode) -> bool:
		var cast := other as NumberLiteral
		if not cast:
			return false
		return value == cast.value

	func _to_string() -> String:
		return JSON.stringify(to_json())

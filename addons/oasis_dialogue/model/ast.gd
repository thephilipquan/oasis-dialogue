extends RefCounted

const _Visitor := preload("res://addons/oasis_dialogue/model/visitor.gd")

class ASTNode:
	extends RefCounted

	func accept(visitor: _Visitor) -> void:
		pass

	func to_json() -> Dictionary:
		return {}

	func equals(other: ASTNode) -> bool:
		return false


class Character:
	extends ASTNode

	var name := ""
	var branches: Dictionary[int, ASTNode] = {}

	func _init(branches: Dictionary[int, ASTNode]) -> void:
		self.branches = branches

	func accept(visitor: _Visitor) -> void:
		branches.values().map(func(n: ASTNode): n.accept(visitor))

	func to_json() -> Dictionary:
		return {
			"branches": branches.values().map(func(n: ASTNode): return n.to_json()),
		}

	func equals(other: ASTNode)-> bool:
		var cast := other as Character
		if not cast:
			return false
		if branches.size() != cast.branches.size():
			return false
		for i in branches.size():
			if not branches[i].equals(cast.branches[i]):
				return false
		return true

	func _to_string() -> String:
		return JSON.stringify(to_json())


class Branch:
	extends ASTNode

	var id := -1
	var annotations: Array[ASTNode] = []
	var prompts: Array[ASTNode] = []
	var responses: Array[ASTNode] = []

	func _init(id: int, annotations: Array[ASTNode], prompts: Array[ASTNode], responses: Array[ASTNode]) -> void:
		self.id = id
		self.annotations = annotations
		self.prompts = prompts
		self.responses = responses

	func accept(visitor: _Visitor) -> void:
		visitor.visit_branch(self)
		annotations.map(func(n: ASTNode): n.accept(visitor))
		prompts.map(func(n: ASTNode): n.accept(visitor))
		responses.map(func(n: ASTNode): n.accept(visitor))

	func to_json() -> Dictionary:
		return {
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

	func to_json() -> Dictionary:
		var map := {
			"name": name,
		}
		if value:
			map["value"] = value.to_json()
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
	var conditions: Array[ASTNode] = []
	var text: ASTNode = null
	var actions: Array[ASTNode] = []

	func _init(conditions: Array[ASTNode], text: StringLiteral, actions: Array[ASTNode]) -> void:
		self.conditions = conditions
		self.text = text
		self.actions = actions

	func accept(visitor: _Visitor) -> void:
		visitor.visit_prompt(self)
		conditions.map(func(n: ASTNode): n.accept(visitor))
		text.accept(visitor)
		actions.map(func(n: ASTNode): n.accept(visitor))

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
	var conditions: Array[ASTNode] = []
	var text: ASTNode = null
	var actions: Array[ASTNode] = []

	func _init(conditions: Array[ASTNode], text: StringLiteral, actions: Array[ASTNode]) -> void:
		self.conditions = conditions
		self.text = text
		self.actions = actions

	func accept(visitor: _Visitor) -> void:
		visitor.visit_response(self)
		conditions.map(func(n: ASTNode): n.accept(visitor))
		text.accept(visitor)
		actions.map(func(n: ASTNode): n.accept(visitor))

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
	var value: ASTNode = null

	func _init(name: String, value: ASTNode) -> void:
		self.name = name
		self.value = value

	func accept(visitor: _Visitor) -> void:
		visitor.visit_condition(self)
		if value:
			value.accept(visitor)

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
	var value: ASTNode = null

	func _init(name: String, value: ASTNode) -> void:
		self.name = name
		self.value = value

	func accept(visitor: _Visitor) -> void:
		visitor.visit_action(self)
		if value:
			value.accept(visitor)

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

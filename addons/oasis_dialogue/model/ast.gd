extends RefCounted

const _Visitor := preload("res://addons/oasis_dialogue/visitor/visitor.gd")
const _JsonUtils := preload("res://addons/oasis_dialogue/utils/json_utils.gd")

const TYPE_BRANCH := "branch"
const TYPE_ANNOTATION := "annotation"
const TYPE_PROMPT := "prompt"
const TYPE_RESPONSE := "response"
const TYPE_CONDITION := "condition"
const TYPE_ACTION := "action"
const TYPE_STRING_LITERAL := "string_literal"
const TYPE_NUMBER_LITERAL := "number_literal"


static func from_json(json) -> AST:
	return AST.from_json(json)


class AST:
	extends RefCounted

	func accept(visitor: _Visitor) -> void:
		pass

	static func from_json(json, instance: AST = null) -> AST:
		if not json is Dictionary:
			return null

		var type: String = _JsonUtils.safe_get(json, "type", "")
		if not type:
			return Recovery.new(json)

		var ast: AST = null
		match type:
			TYPE_BRANCH:
				ast = Branch.from_json(json)
			TYPE_ANNOTATION:
				ast = Annotation.from_json(json)
			TYPE_PROMPT:
				ast = Prompt.from_json(json)
			TYPE_RESPONSE:
				ast = Response.from_json(json)
			TYPE_CONDITION:
				ast = Condition.from_json(json)
			TYPE_ACTION:
				ast = Action.from_json(json)
			TYPE_STRING_LITERAL:
				ast = StringLiteral.from_json(json)
			TYPE_NUMBER_LITERAL:
				ast = NumberLiteral.from_json(json)
			_:
				ast = Recovery.new(json)
		return ast


	func to_json() -> Dictionary:
		assert(false)
		return {}


class Line:
	extends AST

	var line := -1
	var children: Array[AST] = []


	func _init(line := -1, children: Array[AST] = []) -> void:
		self.line = line
		self.children = children


	static func from_json(json, instance: AST = null) -> AST:
		if not instance or not instance is Line:
			instance = new()
		instance.line = _JsonUtils.safe_get_int(json, "line", -1)
		for j in _JsonUtils.safe_get(json, "children", []):
			var child := super.from_json(j)
			instance.add(child)
		return instance


	func add(child: AST) -> void:
		children.push_back(child)


	func remove(child: AST) -> void:
		children.erase(child)


	func accept(visitor: _Visitor) -> void:
		visitor.visit_line(self)
		children.map(func(ast: AST): ast.accept(visitor))


	func to_json() -> Dictionary:
		return {
				"line": line,
				"children": children.map(func(c: AST): return c.to_json()),
		}


class Leaf:
	extends AST

	var line := -1
	var column := -1


	func _init(line := -1, column := -1) -> void:
		self.line = line
		self.column = column


	static func from_json(json, instance: AST = null) -> AST:
		if not instance or not instance is Leaf:
			instance = new()
		instance.line = _JsonUtils.safe_get_int(json, "line", -1)
		return instance


	func to_json() -> Dictionary:
		return {
				"line": line,
		}


class Branch:
	extends Line

	var id := -1


	func _init(id := -1, children: Array[AST] = []) -> void:
		super._init(-1, children)
		self.id = id


	static func from_json(json, instance: AST = null) -> AST:
		instance = new()
		super.from_json(json, instance)
		instance.id = _JsonUtils.safe_get_int(json, "id", -1)
		return instance


	func to_json() -> Dictionary:
		var json := super.to_json()
		json["type"] = TYPE_BRANCH
		json["id"] = id
		return json


	func accept(visitor: _Visitor) -> void:
		visitor.visit_branch(self)
		super.accept(visitor)


	func _to_string() -> String:
		return JSON.stringify(to_json())


class Annotation:
	extends Leaf

	var name := ""

	func _init(name: String, line := -1, column := -1) -> void:
		super._init(line, column)
		self.name = name


	static func from_json(json, instance: AST = null) -> AST:
		if not _JsonUtils.is_typeof(json, "name", TYPE_STRING):
			return Recovery.new(json)
		var name: String = json["name"]
		instance = new(name)
		super.from_json(json, instance)
		return instance


	func to_json() -> Dictionary:
		var json := super.to_json()
		json["type"] = TYPE_ANNOTATION
		json["name"] = name
		return json


	func accept(visitor: _Visitor) -> void:
		visitor.visit_annotation(self)


	func _to_string() -> String:
		return JSON.stringify(to_json())


class Prompt:
	extends Line


	static func from_json(json, instance: AST = null) -> AST:
		return super.from_json(json, new())


	func to_json() -> Dictionary:
		var json := super.to_json()
		json["type"] = TYPE_PROMPT
		return json


	func accept(visitor: _Visitor) -> void:
		visitor.visit_prompt(self)
		super.accept(visitor)


	func _to_string() -> String:
		return JSON.stringify(to_json())


class Response:
	extends Line


	static func from_json(json, instance: AST = null) -> AST:
		return super.from_json(json, new())


	func to_json() -> Dictionary:
		var json := super.to_json()
		json["type"] = TYPE_RESPONSE
		return json


	func accept(visitor: _Visitor) -> void:
		visitor.visit_response(self)
		super.accept(visitor)


	func _to_string() -> String:
		return JSON.stringify(to_json())


class Condition:
	extends Leaf

	var name := ""
	var value: NumberLiteral = null


	func _init(name: String, value: AST = null, line := -1, column := -1) -> void:
		super._init(line, column)
		self.name = name
		self.value = value


	static func from_json(json, instance: AST = null) -> AST:
		if not _JsonUtils.is_typeof(json, "name", TYPE_STRING):
			return Recovery.new(json)
		var name: String = json["name"]
		instance = new(name)
		super.from_json(json, instance)

		if "value" in json:
			instance.value = AST.from_json(json["value"])

		return instance


	func to_json() -> Dictionary:
		var json := super.to_json()
		json["type"] = TYPE_CONDITION
		json["name"] = name
		if value:
			json["value"] = value.to_json()
		return json


	func accept(visitor: _Visitor) -> void:
		visitor.visit_condition(self)
		if value:
			value.accept(visitor)


	func _to_string() -> String:
		return JSON.stringify(to_json())


class Action:
	extends Leaf

	var name := ""
	var value: NumberLiteral = null


	func _init(name: String, value: AST = null, line := -1, column := -1) -> void:
		super._init(line, column)
		self.name = name
		self.value = value


	static func from_json(json, instance: AST = null) -> AST:
		if not _JsonUtils.is_typeof(json, "name", TYPE_STRING):
			return Recovery.new(json)
		var name: String = json["name"]
		instance = new(name)
		super.from_json(json, instance)

		if "value" in json:
			instance.value = AST.from_json(json["value"])

		return instance


	func to_json() -> Dictionary:
		var json := super.to_json()
		json["type"] = TYPE_ACTION
		json["name"] = name
		if value:
			json["value"] = value.to_json()
		return json


	func accept(visitor: _Visitor) -> void:
		visitor.visit_action(self)
		if value:
			value.accept(visitor)


	func equals(other) -> bool:
		var cast := other as Action
		if not cast:
			return false
		if name != cast.name:
			return false
		return (
			(value != null and value.equals(cast.value))
			or value == cast.value
		)

	func _to_string() -> String:
		return JSON.stringify(to_json())


class StringLiteral:
	extends Leaf

	var value := ""


	func _init(value: String, line := -1, column := -1) -> void:
		super._init(line, column)
		self.value = value


	static func from_json(json, instance: AST = null) -> AST:
		if not _JsonUtils.is_typeof(json, "value", TYPE_STRING):
			return Recovery.new(json)
		var value: String = json["value"]
		instance = new(value)
		super.from_json(json, instance)
		return instance


	func to_json() -> Dictionary:
		var json := super.to_json()
		json["type"] = TYPE_STRING_LITERAL
		json["value"] = value
		return json


	func accept(visitor: _Visitor) -> void:
		visitor.visit_stringliteral(self)


	func equals(other: AST) -> bool:
		var cast := other as StringLiteral
		if not cast:
			return false
		return value == cast.value


	func _to_string() -> String:
		return JSON.stringify(to_json())


class NumberLiteral:
	extends Leaf

	var value := -1


	func _init(value: int, line := -1, column := -1) -> void:
		super._init(line, column)
		self.value = value


	static func from_json(json, instance: AST = null) -> AST:
		if not _JsonUtils.is_int(json.get("value")):
			return Recovery.new(json)
		var value := _JsonUtils.parse_int(json["value"])
		instance = new(value)
		super.from_json(json, instance)
		return instance


	func to_json() -> Dictionary:
		var json := super.to_json()
		json["type"] = TYPE_NUMBER_LITERAL
		json["value"] = value
		return json


	func accept(visitor: _Visitor) -> void:
		visitor.visit_numberliteral(self)


	func equals(other: AST) -> bool:
		var cast := other as NumberLiteral
		if not cast:
			return false
		return value == cast.value


	func _to_string() -> String:
		return JSON.stringify(to_json())


class Error:
	extends Leaf

	var message := ""


	func _init(message: String, line: int, column: int) -> void:
		super._init(line, column)
		self.message = message


	func accept(visitor: _Visitor) -> void:
		visitor.visit_error(self)


class Recovery:
	extends Leaf

	var message := ""


	func _init(malformed_data) -> void:
		line = _JsonUtils.safe_get_int(malformed_data, "line", -1)
		message = "ERROR(%s)" % JSON.stringify(malformed_data)


	func accept(visitor: _Visitor) -> void:
		visitor.visit_recovery(self)

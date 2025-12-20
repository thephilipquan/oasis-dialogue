extends RefCounted

const _Visitor := preload("res://addons/oasis_dialogue/definitions/visitor/visitor.gd")


@abstract
class AST:
	extends RefCounted

	@abstract
	func accept(visitor: _Visitor) -> void


class Program:
	extends AST

	var children: Array[AST] = []


	func accept(visitor: _Visitor) -> void:
		visitor.visit_program(self)
		for c in children:
			c.accept(visitor)


	func _to_string() -> String:
		return str(children)


class Declaration:
	extends AST

	var children: Array[Leaf] = []


	func accept(visitor: _Visitor) -> void:
		visitor.visit_declaration(self)
		for c in children:
			c.accept(visitor)


	func _to_string() -> String:
		return str(children)


@abstract
class Leaf:
	extends AST

	var line := -1
	var column := -1

	func _init(line: int, column: int) -> void:
		self.line = line
		self.column = column


	func to_json() -> Dictionary:
		return {
				"line": line,
				"column": column,
		}


@abstract
class LeafValue:
	extends Leaf

	var value := ""

	func _init(value: String, line: int, column: int) -> void:
		super._init(line, column)
		self.value = value


	func to_json() -> Dictionary:
		var d := super.to_json()
		d.value = value
		return d


	func _to_string() -> String:
		return JSON.stringify(to_json())


class Annotation:
	extends LeafValue


	func accept(visitor: _Visitor) -> void:
		visitor.visit_annotation(self)


class Identifier:
	extends LeafValue


	func accept(visitor: _Visitor) -> void:
		visitor.visit_identifier(self)


class Description:
	extends LeafValue


	func accept(visitor: _Visitor) -> void:
		visitor.visit_description(self)


class Error:
	extends Leaf

	var message := ""

	@warning_ignore("shadowed_variable")
	func _init(message: String, line: int, column: int) -> void:
		super._init(line, column)
		self.message = message


	func accept(visitor: _Visitor) -> void:
		visitor.visit_error(self)


	func to_json() -> Dictionary:
		var d := super.to_json()
		d.message = message
		return d


	func _to_string() -> String:
		return JSON.stringify(to_json())

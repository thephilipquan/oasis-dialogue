extends RefCounted

const _Visitor := preload("res://addons/oasis_dialogue/visitor/visitor.gd")


class AST:
	extends RefCounted

	func accept(_visitor: _Visitor) -> void:
		pass


class Line:
	extends AST

	var line := -1
	var children: Array[AST] = []


	@warning_ignore("shadowed_variable")
	func _init(line := -1, children: Array[AST] = []) -> void:
		self.line = line
		self.children = children


	func add(child: AST) -> void:
		children.push_back(child)


	func remove(child: AST) -> void:
		children.erase(child)


	func accept(visitor: _Visitor) -> void:
		visitor.visit_line(self)
		children.map(func(ast: AST) -> void: ast.accept(visitor))


class Leaf:
	extends AST

	var line := -1
	var column := -1


	@warning_ignore("shadowed_variable")
	func _init(line := -1, column := -1) -> void:
		self.line = line
		self.column = column


class Branch:
	extends Line

	var id := -1


	@warning_ignore("shadowed_variable", "shadowed_variable_base_class")
	func _init(id := -1, children: Array[AST] = []) -> void:
		super._init(-1, children)
		self.id = id


	func accept(visitor: _Visitor) -> void:
		visitor.visit_branch(self)
		super.accept(visitor)


class Annotation:
	extends Leaf

	var name := ""

	@warning_ignore("shadowed_variable", "shadowed_variable_base_class")
	func _init(name: String, line := -1, column := -1) -> void:
		super._init(line, column)
		self.name = name


	func accept(visitor: _Visitor) -> void:
		visitor.visit_annotation(self)


class Prompt:
	extends Line


	func accept(visitor: _Visitor) -> void:
		visitor.visit_prompt(self)
		super.accept(visitor)


class Response:
	extends Line


	func accept(visitor: _Visitor) -> void:
		visitor.visit_response(self)
		super.accept(visitor)


class Condition:
	extends Leaf

	var name := ""
	var value: NumberLiteral = null


	@warning_ignore("shadowed_variable", "shadowed_variable_base_class")
	func _init(name: String, value: AST = null, line := -1, column := -1) -> void:
		super._init(line, column)
		self.name = name
		self.value = value


	func accept(visitor: _Visitor) -> void:
		visitor.visit_condition(self)
		if value:
			value.accept(visitor)


class Action:
	extends Leaf

	var name := ""
	var value: NumberLiteral = null


	@warning_ignore("shadowed_variable", "shadowed_variable_base_class")
	func _init(name: String, value: AST = null, line := -1, column := -1) -> void:
		super._init(line, column)
		self.name = name
		self.value = value


	func accept(visitor: _Visitor) -> void:
		visitor.visit_action(self)
		if value:
			value.accept(visitor)


class StringLiteral:
	extends Leaf

	var value := ""


	@warning_ignore("shadowed_variable", "shadowed_variable_base_class")
	func _init(value: String, line := -1, column := -1) -> void:
		super._init(line, column)
		self.value = value


	func accept(visitor: _Visitor) -> void:
		visitor.visit_stringliteral(self)


class NumberLiteral:
	extends Leaf

	var value := -1


	@warning_ignore("shadowed_variable", "shadowed_variable_base_class")
	func _init(value: int, line := -1, column := -1) -> void:
		super._init(line, column)
		self.value = value


	func accept(visitor: _Visitor) -> void:
		visitor.visit_numberliteral(self)


class Error:
	extends Leaf

	var message := ""


	@warning_ignore("shadowed_variable", "shadowed_variable_base_class")
	func _init(message: String, line: int, column: int) -> void:
		super._init(line, column)
		self.message = message


	func accept(visitor: _Visitor) -> void:
		visitor.visit_error(self)

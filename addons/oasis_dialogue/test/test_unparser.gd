extends GutTest

const Unparser := preload("res://addons/oasis_dialogue/visitor/unparser_visitor.gd")
const AST := preload("res://addons/oasis_dialogue/model/ast.gd")


func test_callable_passes_branch_id() -> void:
	var sut := Unparser.new(func(id, text): assert_eq(id, 13))
	var ast := AST.Branch.new(13)

	ast.accept(sut)
	sut.finish()


func test_lines_are_inserted_according_to_ast_line() -> void:
	var sut := Unparser.new(
			func(id, text):
				assert_eq(text, "\n\n\n\n\n")
	)
	var ast := AST.Branch.new(
			-1,
			[
				AST.StringLiteral.new("", 2),
				AST.StringLiteral.new("", 5),
			]
	)

	ast.accept(sut)
	sut.finish()


func test_restoring_prompt_inserts_header_above_first_prompt_child() -> void:
	var sut := Unparser.new(
			func(id, text):
				assert_eq(text, "\n\n@prompt\nfoo\nbar")

	)
	var ast := AST.Branch.new(
			-1,
			[
				AST.Prompt.new(
					-1,
					[
						AST.StringLiteral.new("foo", 3)
					]
				),
				AST.Prompt.new(
					-1,
					[
						AST.StringLiteral.new("bar", 4)
					]
				),
			]
	)

	ast.accept(sut)
	sut.finish()


func test_restoring_response_inserts_header_above_first_response_child() -> void:
	var sut := Unparser.new(
			func(id, text):
				assert_eq(text, "\n@response\nfoo\nbar")
	)
	var ast := AST.Branch.new(
			-1,
			[
				AST.Response.new(
					-1,
					[
						AST.StringLiteral.new("foo", 2),
					]
				),
				AST.Response.new(
					-1,
					[
						AST.StringLiteral.new("bar", 3),
					]
				),
			]
	)

	ast.accept(sut)
	sut.finish()


func test_annotations_have_atsign_inserted() -> void:
	var sut := Unparser.new(
			func(id: int, text: String):
				assert_eq(text, "@foo\n@bar")
	)
	var ast := AST.Branch.new(
			-1,
			[
				AST.Annotation.new("foo", 0),
				AST.Annotation.new("bar", 1),
			]
	)

	ast.accept(sut)
	sut.finish()


func test_condition() -> void:
	var sut := Unparser.new(
			func(id, text):
				assert_eq(text, "{ foo }")
	)
	var ast := AST.Branch.new(
			-1,
			[
				AST.Condition.new("foo", null, 0),
			],
	)

	ast.accept(sut)
	sut.finish()


func test_condition_with_value() -> void:
	var sut := Unparser.new(
			func(id, text):
				assert_eq(text, "{ foo 3 }")
	)
	var ast := AST.Branch.new(
			-1,
			[
				AST.Condition.new(
					"foo",
					AST.NumberLiteral.new(3),
					0,
				),
			],
	)

	ast.accept(sut)
	sut.finish()


func test_multiple_conditions() -> void:
	var sut := Unparser.new(
			func(id, text):
				assert_eq(text, "{ foo bar 3 baz 2 }")
	)
	var ast := AST.Branch.new(
			-1,
			[
				AST.Condition.new(
					"foo",
					null,
					0,
				),
				AST.Condition.new(
					"bar",
					AST.NumberLiteral.new(3),
					0,
				),
				AST.Condition.new(
					"baz",
					AST.NumberLiteral.new(2),
					0,
				),
			],
	)

	ast.accept(sut)
	sut.finish()


func test_action() -> void:
	var sut := Unparser.new(
			func(id, text):
				# Action will always come after text.
				assert_eq(text, " { foo }")
	)
	var ast := AST.Branch.new(
			-1,
			[
				AST.Action.new("foo", null, 0),
			],
	)

	ast.accept(sut)
	sut.finish()


func test_action_with_value() -> void:
	var sut := Unparser.new(
			func(id, text):
				# Action will always come after text.
				assert_eq(text, " { foo 3 }")
	)
	var ast := AST.Branch.new(
			-1,
			[
				AST.Action.new(
					"foo",
					AST.NumberLiteral.new(3, 0),
					0,
				),
			],
	)

	ast.accept(sut)
	sut.finish()


func test_multiple_actions() -> void:
	var sut := Unparser.new(
			func(id, text):
				# Action will always come after text.
				assert_eq(text, " { foo bar 3 baz 2 }")
	)
	var ast := AST.Branch.new(
			-1,
			[
				AST.Action.new(
					"foo",
					null,
					0,
				),
				AST.Action.new(
					"bar",
					AST.NumberLiteral.new(3),
					0,
				),
				AST.Action.new(
					"baz",
					AST.NumberLiteral.new(2),
					0,
				),
			],
	)

	ast.accept(sut)
	sut.finish()


func test_moving_to_new_line_closes_curly_from_previous_action() -> void:
	var sut := Unparser.new(
			func(id, text):
				# Action will always come after text.
				assert_eq(text, " { foo }\n{ bar }")
	)
	var ast := AST.Branch.new(
			-1,
			[
				AST.Action.new("foo", null, 0),
				AST.Condition.new("bar", null, 1),
			],

	)

	ast.accept(sut)
	sut.finish()


func test_condition_with_string_literal() -> void:
	var sut := Unparser.new(
			func(id, text):
				assert_eq(text, "{ foo } hello world")
	)
	var ast := AST.Branch.new(
			-1,
			[
				AST.Condition.new("foo", null, 0),
				AST.StringLiteral.new("hello world", 0),
			],

	)

	ast.accept(sut)
	sut.finish()


func test_string_literal_with_action() -> void:
	var sut := Unparser.new(
			func(id, text):
				assert_eq(text, "hello world { foo }")
	)
	var ast := AST.Branch.new(
			-1,
			[
				AST.StringLiteral.new("hello world", 0),
				AST.Action.new("foo", null, 0),
			],

	)

	ast.accept(sut)
	sut.finish()


func test_condition_string_literal_and_action() -> void:
	var sut := Unparser.new(
			func(id, text):
				assert_eq(text, "{ foo } hello world { bar }")
	)
	var ast := AST.Branch.new(
			-1,
			[
				AST.Condition.new("foo", null, 0),
				AST.StringLiteral.new("hello world", 0),
				AST.Action.new("bar", null, 0),
			],

	)

	ast.accept(sut)
	sut.finish()

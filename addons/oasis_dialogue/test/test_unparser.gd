extends GutTest

const Unparser := preload("res://addons/oasis_dialogue/model/unparser_visitor.gd")
const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
var sut: Unparser = null


func before_all() -> void:
	sut = Unparser.new()


func after_each() -> void:
	sut.finish()


func test_basic_annotations() -> void:
	var root := AST.Annotation.new("rng", null)

	root.accept(sut)

	var expected = "@rng"
	assert_eq(sut.get_text(), expected)


func test_annotations_with_value() -> void:
	var root := AST.Annotation.new("id", AST.NumberLiteral.new(27))

	root.accept(sut)

	var expected = "@id 27"
	assert_eq(sut.get_text(), expected)


func test_prompt() -> void:
	var root := AST.Prompt.new(
		[],
		AST.StringLiteral.new("foo"),
		[],
	)

	root.accept(sut)

	var expected = "@prompt\nfoo"
	assert_eq(sut.get_text(), expected)


func test_prompt_with_condition() -> void:
	var root := AST.Prompt.new(
		[
			AST.Condition.new("has_gold", AST.NumberLiteral.new(2)),
		],
		AST.StringLiteral.new("foo"),
		[],
	)

	root.accept(sut)

	var expected = "@prompt\n{ has_gold 2 } foo"
	assert_eq(sut.get_text(), expected)


func test_prompt_with_action() -> void:
	var root := AST.Prompt.new(
		[],
		AST.StringLiteral.new("foo"),
		[
			AST.Action.new("bar", AST.NumberLiteral.new(2)),
		],
	)

	root.accept(sut)

	var expected = "@prompt\nfoo { bar 2 }"
	assert_eq(sut.get_text(), expected)


func test_response() -> void:
	var root := AST.Response.new(
		[],
		AST.StringLiteral.new("foo"),
		[],
	)

	root.accept(sut)

	var expected = "@response\nfoo"
	assert_eq(sut.get_text(), expected)


func test_response_with_condition() -> void:
	var root := AST.Response.new(
		[
			AST.Condition.new("has_gold", AST.NumberLiteral.new(2)),
		],
		AST.StringLiteral.new("foo"),
		[],
	)

	root.accept(sut)

	var expected = "@response\n{ has_gold 2 } foo"
	assert_eq(sut.get_text(), expected)


func test_response_with_action() -> void:
	var root := AST.Response.new(
		[],
		AST.StringLiteral.new("foo"),
		[
			AST.Action.new("bar", AST.NumberLiteral.new(2)),
		],
	)

	root.accept(sut)

	var expected = "@response\nfoo { bar 2 }"
	assert_eq(sut.get_text(), expected)


func test_condition() -> void:
	var root := AST.Condition.new("foo", null)

	root.accept(sut)

	var expected = "{ foo }"
	assert_eq(sut.get_text(), expected)


func test_condition_with_value() -> void:
	var root := AST.Condition.new("foo", AST.NumberLiteral.new(28))

	root.accept(sut)

	var expected = "{ foo 28 }"
	assert_eq(sut.get_text(), expected)


func test_action() -> void:
	var root := AST.Action.new("foo", null)

	root.accept(sut)

	# Expected should begin with a space as no action will exist without text.
	var expected = " { foo }"
	assert_eq(sut.get_text(), expected)


func test_action_with_value() -> void:
	var root := AST.Action.new("foo", AST.NumberLiteral.new(28))

	root.accept(sut)

	# Expected should begin with a space as no action will exist without text.
	var expected = " { foo 28 }"
	assert_eq(sut.get_text(), expected)


func test_multiple_annotations() -> void:
	var root := AST.Branch.new(
		-1,
		[
			AST.Annotation.new("rng", null),
			AST.Annotation.new("unique", null),
			AST.Annotation.new("id", AST.NumberLiteral.new(2)),
		],
		[],
		[],
	)

	root.accept(sut)

	var expected = "@rng\n@unique\n@id 2"
	assert_eq(sut.get_text(), expected)


func test_no_annotations_with_prompt() -> void:
	var root := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("foobar"),
				[],
			),
		],
		[],
	)

	root.accept(sut)

	var expected = "@prompt\nfoobar"
	assert_eq(sut.get_text(), expected)


func test_no_annotations_with_response() -> void:
	var root := AST.Branch.new(
		-1,
		[],
		[],
		[
			AST.Response.new(
				[],
				AST.StringLiteral.new("foobar"),
				[],
			),
		],
	)

	root.accept(sut)

	var expected = "@response\nfoobar"
	assert_eq(sut.get_text(), expected)

func test_prompt_and_response() -> void:
	var root := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("foo"),
				[],
			),
		],
		[
			AST.Response.new(
				[],
				AST.StringLiteral.new("bar"),
				[],
			),
		],
	)

	root.accept(sut)

	var expected = "@prompt\nfoo\n@response\nbar"
	assert_eq(sut.get_text(), expected)


func test_prompt_with_action_and_response() -> void:
	var root := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("foo"),
				[ AST.Action.new("do_thing", null) ],
			),
		],
		[
			AST.Response.new(
				[],
				AST.StringLiteral.new("bar"),
				[],
			),
		],
	)

	root.accept(sut)

	var expected = "@prompt\nfoo { do_thing }\n@response\nbar"
	assert_eq(sut.get_text(), expected)


func test_multiple_prompts() -> void:
	var root := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("foo"),
				[ AST.Action.new("a", null) ],
			),
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("bar"),
				[],
			),
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("baz"),
				[ AST.Action.new("c", null) ],
			),
		],
		[],
	)

	root.accept(sut)

	var expected = "@prompt\nfoo { a }\nbar\nbaz { c }"
	assert_eq(sut.get_text(), expected)


func test_multiple_responses() -> void:
	var root := AST.Branch.new(
		-1,
		[],
		[],
		[
			AST.Response.new(
				[],
				AST.StringLiteral.new("foo"),
				[ AST.Action.new("a", null) ],
			),
			AST.Response.new(
				[],
				AST.StringLiteral.new("bar"),
				[],
			),
			AST.Response.new(
				[],
				AST.StringLiteral.new("baz"),
				[ AST.Action.new("c", null) ],
			),
		],
	)

	root.accept(sut)

	var expected = "@response\nfoo { a }\nbar\nbaz { c }"
	assert_eq(sut.get_text(), expected)


func test_multiple_prompts_and_responses() -> void:
	var root := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("foo"),
				[ AST.Action.new("a", null) ],
			),
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("bar"),
				[],
			),
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("baz"),
				[ AST.Action.new("c", null) ],
			),
		],
		[
			AST.Response.new(
				[],
				AST.StringLiteral.new("foo"),
				[ AST.Action.new("a", null) ],
			),
			AST.Response.new(
				[],
				AST.StringLiteral.new("bar"),
				[],
			),
			AST.Response.new(
				[],
				AST.StringLiteral.new("baz"),
				[ AST.Action.new("c", null) ],
			),
		],
	)

	root.accept(sut)

	var expected = "@prompt\nfoo { a }\nbar\nbaz { c }\n@response\nfoo { a }\nbar\nbaz { c }"
	assert_eq(sut.get_text(), expected)


func test_cancel_clears_members() -> void:
	var root := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("foo"),
				[ AST.Action.new("do_thing", null) ],
			),
		],
		[
			AST.Response.new(
				[],
				AST.StringLiteral.new("bar"),
				[],
			),
		],
	)

	root.accept(sut)
	sut.cancel()

	assert_eq(sut._text, "")
	assert_eq(sut._in_annotation, false)
	assert_eq(sut._in_curly, false)
	assert_eq(sut._seen_prompt, false)
	assert_eq(sut._seen_response, false)


func test_finish_clears_members() -> void:
	var root := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("foo"),
				[ AST.Action.new("do_thing", null) ],
			),
		],
		[
			AST.Response.new(
				[],
				AST.StringLiteral.new("bar"),
				[],
			),
		],
	)

	root.accept(sut)
	sut.finish()

	assert_eq(sut._text, "")
	assert_eq(sut._in_annotation, false)
	assert_eq(sut._in_curly, false)
	assert_eq(sut._seen_prompt, false)
	assert_eq(sut._seen_response, false)

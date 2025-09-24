extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const RemoveAction := preload("res://addons/oasis_dialogue/model/remove_action_visitor.gd")

var sut: RemoveAction = null


func before_each() -> void:
	sut = add_child_autofree(RemoveAction.new())


func test_only_specified_branch_removed() -> void:
	var ast := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("foo"),
				[
					AST.Action.new("something", AST.NumberLiteral.new(5)),
					AST.Action.new("something", AST.NumberLiteral.new(3)),
				],
			),
		],
		[
			AST.Response.new(
				[],
				AST.StringLiteral.new("bar"),
				[
					AST.Action.new("something", AST.NumberLiteral.new(3)),
				],
			),
		],
	)
	sut.init(AST.Action.new("something", AST.NumberLiteral.new(3)))

	ast.accept(sut)

	var prompt_actions := (ast.prompts[0] as AST.Prompt).actions
	assert_eq(prompt_actions.size(), 1)

	var response_actions := (ast.responses[0] as AST.Response).actions
	assert_eq(response_actions.size(), 0)


func test_no_match_stays_unchanged() -> void:
	var ast := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("foo"),
				[
					AST.Action.new("something", AST.NumberLiteral.new(5)),
				],
			),
		],
		[
			AST.Response.new(
				[],
				AST.StringLiteral.new("bar"),
				[
					AST.Action.new("something", AST.NumberLiteral.new(2)),
				],
			),
		],
	)
	sut.init(AST.Action.new("something", AST.NumberLiteral.new(3)))

	ast.accept(sut)

	var prompt_actions := (ast.prompts[0] as AST.Prompt).actions
	assert_eq(prompt_actions.size(), 1)

	var response_actions := (ast.responses[0] as AST.Response).actions
	assert_eq(response_actions.size(), 1)


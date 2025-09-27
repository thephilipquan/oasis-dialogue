extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const RemoveAction := preload("res://addons/oasis_dialogue/visitor/remove_action_visitor.gd")

const ACTION := "foo"
const OTHER_ACTION := "bar"

var sut: RemoveAction = null


func after_each() -> void:
	sut = null


func test_only_specified_branch_removed() -> void:
	sut = RemoveAction.new(AST.Action.new(ACTION, AST.NumberLiteral.new(3)))
	var ast := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new(OTHER_ACTION),
				[
					AST.Action.new(ACTION, AST.NumberLiteral.new(5)),
					AST.Action.new(ACTION, AST.NumberLiteral.new(3)),
				],
			),
		],
		[
			AST.Response.new(
				[],
				AST.StringLiteral.new("hello world"),
				[
					AST.Action.new(ACTION, AST.NumberLiteral.new(3)),
				],
			),
		],
	)

	ast.accept(sut)

	var prompt_actions := (ast.prompts[0] as AST.Prompt).actions
	assert_eq(prompt_actions.size(), 1)

	var response_actions := (ast.responses[0] as AST.Response).actions
	assert_eq(response_actions.size(), 0)


func test_no_match_stays_unchanged() -> void:
	sut = RemoveAction.new(AST.Action.new(ACTION, AST.NumberLiteral.new(3)))
	var ast := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("hello world"),
				[
					AST.Action.new(ACTION, AST.NumberLiteral.new(5)),
				],
			),
		],
		[
			AST.Response.new(
				[],
				AST.StringLiteral.new("hello world again"),
				[
					AST.Action.new(ACTION, AST.NumberLiteral.new(2)),
				],
			),
		],
	)

	ast.accept(sut)

	var prompt_actions := (ast.prompts[0] as AST.Prompt).actions
	assert_eq(prompt_actions.size(), 1)

	var response_actions := (ast.responses[0] as AST.Response).actions
	assert_eq(response_actions.size(), 1)

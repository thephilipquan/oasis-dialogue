extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const CreateBranch := preload("res://addons/oasis_dialogue/visitor/create_branch_visitor.gd")
const Model := preload("res://addons/oasis_dialogue/model/model.gd")
const Graph := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")

const BRANCH_KEYWORD := "foo"

var sut: CreateBranch = null
var model: Model = null
var graph: Graph = null


func before_each() -> void:
	model = double(Model).new()
	graph = double(Graph).new()
	sut = CreateBranch.new(BRANCH_KEYWORD, model, graph)


func test_new_branch() -> void:
	stub(model.has_branch).to_return(false)
	var ast := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("hey"),
				[
					AST.Action.new(BRANCH_KEYWORD, AST.NumberLiteral.new(3)),
				],
			),
		],
		[],
	)

	ast.accept(sut)
	sut.finish()

	assert_called(model, "add_branch", [3])
	assert_called(graph, "add_branch", [3])


func test_existing_branch() -> void:
	stub(model.has_branch).to_return(true)
	var ast := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("hey"),
				[
					AST.Action.new(BRANCH_KEYWORD, AST.NumberLiteral.new(3)),
				],
			),
		],
		[],
	)

	ast.accept(sut)
	sut.finish()

	assert_not_called(model.add_branch)
	assert_not_called(graph.add_branch)


func test_not_action_keyword() -> void:
	stub(model.has_branch).to_return(true)
	var ast := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("hey"),
				[
					AST.Action.new(BRANCH_KEYWORD + "bar", AST.NumberLiteral.new(3)),
				],
			),
		],
		[],
	)

	ast.accept(sut)
	sut.finish()

	assert_not_called(model.add_branch)
	assert_not_called(graph.add_branch)


func test_none_created_on_cancel() -> void:
	stub(model.has_branch).to_return(false)
	var ast := AST.Branch.new(
		-1,
		[],
		[
			AST.Prompt.new(
				[],
				AST.StringLiteral.new("hey"),
				[
					AST.Action.new(BRANCH_KEYWORD, AST.NumberLiteral.new(3)),
				],
			),
		],
		[],
	)

	ast.accept(sut)
	sut.cancel()

	assert_not_called(model.add_branch)
	assert_not_called(graph.add_branch)

extends GutTest

const Global := preload("res://addons/oasis_dialogue/global.gd")

const Canvas := preload("res://addons/oasis_dialogue/canvas/canvas.gd")
const CanvasScene := preload("res://addons/oasis_dialogue/canvas/canvas.tscn")
const CanvasInit := preload("res://addons/oasis_dialogue/canvas/canvas_init.gd")
const Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const BranchScene := preload("res://addons/oasis_dialogue/branch/branch.tscn")

const Model := preload("res://addons/oasis_dialogue/model/model.gd")
const Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")
const Parser := preload("res://addons/oasis_dialogue/model/parser.gd")
const Unparser := preload("res://addons/oasis_dialogue/model/unparser_visitor.gd")
const VisitorIterator := preload("res://addons/oasis_dialogue/model/visitor_iterator.gd")
const Highlighter := preload("res://addons/oasis_dialogue/branch/highlighter.gd")

const Token := preload("res://addons/oasis_dialogue/model/token.gd")
const AST := preload("res://addons/oasis_dialogue/model/ast.gd")

const InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.gd")
const InputDialogScene := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.tscn")
const ConfirmDialog := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.gd")
const ConfirmDialogScene := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.tscn")
const OasisDialog := preload("res://addons/oasis_dialogue/file_dialog/oasis_dialog.gd")

var sut: Canvas = null
var init: CanvasInit = null
var model: Model = null
var lexer: Lexer = null
var parser: Parser = null
var unparser: Unparser = null
var visitor_iterator: VisitorIterator = null
var unbranchers: VisitorIterator = null
var branch_factory := Callable()
var input_dialog_factory := Callable()
var confirm_dialog_factory := Callable()
var unbranchers_factory := Callable()
var oasis_dialog_factory := Callable()

var doubled_branches: Array[Branch] = []
var doubled_input_dialogs: Array[InputDialog] = []
var doubled_confirm_dialogs: Array[ConfirmDialog] = []
var doubled_oasis_dialogs: Array[OasisDialog] = []

func before_all() -> void:
	model = double(Model).new()
	lexer = double(Lexer).new()
	parser = double(Parser).new()
	unparser = double(Unparser).new()
	visitor_iterator = double(VisitorIterator).new()
	input_dialog_factory = func():
		var dialog: InputDialog = InputDialogScene.instantiate()
		doubled_input_dialogs.push_back(dialog)
		return dialog
	confirm_dialog_factory = func():
		var dialog: ConfirmDialog = ConfirmDialogScene.instantiate()
		doubled_confirm_dialogs.push_back(dialog)
		return dialog
	branch_factory = func():
		var branch: Branch = double(BranchScene).instantiate()
		doubled_branches.push_back(branch)
		return branch
	unbranchers_factory = func(id: int):
		unbranchers = double(VisitorIterator).new()
		return unbranchers
	oasis_dialog_factory = func():
		var dialog := OasisDialog.new()
		doubled_oasis_dialogs.push_back(dialog)
		return dialog

	init = CanvasInit.new()
	init.model = model
	init.lexer = lexer
	init.parser = parser
	init.unparser = unparser
	init.visitors = visitor_iterator
	init.branch_factory = branch_factory
	init.input_dialog_factory = input_dialog_factory
	init.confirm_dialog_factory = confirm_dialog_factory
	init.unbranchers_factory = unbranchers_factory
	init.save_dialog_factory = oasis_dialog_factory
	init.load_dialog_factory = oasis_dialog_factory


func before_each() -> void:
	doubled_branches.clear()
	doubled_input_dialogs.clear()
	doubled_confirm_dialogs.clear()
	doubled_oasis_dialogs.clear()
	sut = partial_double(CanvasScene).instantiate()
	sut.init(init)
	add_child_autofree(sut)


func test_init() -> void:
	assert_ne(sut._lexer, null)
	assert_ne(sut._parser, null)
	assert_ne(sut._unparser, null)
	assert_ne(sut._visitors, null)
	assert_ne(sut._branch_factory , Callable())
	assert_ne(sut._input_dialog_factory , Callable())
	assert_ne(sut._confirm_dialog_factory , Callable())
	assert_ne(sut._unbranchers_factory , Callable())


func test_add_character() -> void:
	sut._on_add_character_button_up()
	stub(model.get_branches).to_call(
		func():
			var branches: Dictionary[int, AST.Branch] = {}
			return branches
	)
	var input_dialog := doubled_input_dialogs[0]
	input_dialog._on_done.call("fred")
	await wait_physics_frames(1)

	assert_called(model.add_character)
	assert_called(model.switch_character)
	assert_eq(sut._character_tree.get_root().get_child_count(), 1)


func test_cancelling_add_character() -> void:
	sut._on_add_character_button_up()
	var input_dialog := doubled_input_dialogs[0]
	input_dialog._on_cancel.call()
	await wait_physics_frames(1)

	assert_not_called(model.add_character)
	assert_not_called(model.switch_character)
	assert_eq(sut._character_tree.get_root().get_child_count(), 0)


func test_add_branch_with_no_characters() -> void:
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {}
			return characters
	)
	sut._on_add_branch_button_up()

	assert_not_called(model.add_branch)
	assert_ne(sut._status.text, "")


func test_add_branch_with_no_active_character() -> void:
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("")

	sut._on_add_branch_button_up()

	assert_not_called(model.add_branch)


func test_remove_character_with_no_branches() -> void:
	# Add character.
	sut._on_add_character_button_up()
	stub(model.get_branches).to_call(
		func():
			var branches: Dictionary[int, AST.Branch] = {}
			return branches
	)
	var input_dialog := doubled_input_dialogs[0]
	input_dialog._on_done.call("fred")
	await wait_physics_frames(1)

	sut._on_remove_character_button_up()

	assert_called(model.remove_character)
	assert_eq(sut._character_tree.get_root().get_child_count(), 0)
	assert_eq(sut._branches.size(), 0)


func test_remove_character_with_branches_confirmed() -> void:
	# Add character.
	sut._on_add_character_button_up()
	stub(model.get_branches).to_call(
		func():
			var branches: Dictionary[int, AST.Branch] = {}
			return branches
	)
	var input_dialog := doubled_input_dialogs[0]
	input_dialog._on_done.call("fred")
	await wait_physics_frames(1)

	# Add branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(0))
	sut._on_add_branch_button_up()

	stub(model.get_branches).to_call(
		func():
			var branches: Dictionary[int, AST.Branch] = {
				0: AST.Branch.new(-1, [], [], []),
			}
			return branches
	)
	sut._on_remove_character_button_up()

	var confirm_dialog := doubled_confirm_dialogs[0]
	confirm_dialog._on_confirm.call()
	await wait_physics_frames(1)

	assert_called(model.remove_character)
	assert_eq(sut._character_tree.get_root().get_child_count(), 0)
	assert_eq(sut._branches.size(), 0)


func test_remove_character_with_branches_canceled() -> void:
	# Add character.
	sut._on_add_character_button_up()
	stub(model.get_branches).to_call(
		func():
			var branches: Dictionary[int, AST.Branch] = {}
			return branches
	)
	var input_dialog := doubled_input_dialogs[0]
	input_dialog._on_done.call("fred")
	await wait_physics_frames(1)

	# Add branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(0))
	sut._on_add_branch_button_up()

	stub(model.get_branches).to_call(
		func():
			var branches: Dictionary[int, AST.Branch] = {
				0: AST.Branch.new(-1, [], [], []),
			}
			return branches
	)
	sut._on_remove_character_button_up()

	var confirm_dialog := doubled_confirm_dialogs[0]
	confirm_dialog._on_cancel.call()
	await wait_physics_frames(1)

	assert_not_called(model.remove_character)
	assert_ne(sut._character_tree.get_root().get_child_count(), 0)
	assert_ne(sut._branches.size(), 0)


func test_add_branch() -> void:
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(3))

	sut._on_add_branch_button_up()

	assert_eq(sut._branches.size(), 1)


func test_on_model_branch_added() -> void:
	sut._add_branch(5)

	var branch := doubled_branches[0]
	assert_called(branch.set_on_remove)
	assert_called(branch.set_id)


func test_parser_error() -> void:
	# Add branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(3))
	sut._on_add_branch_button_up()

	# Branch changes.
	stub(lexer.tokenize).to_call(
		func(s: String):
			var tokens: Array[Token] = []
			return tokens
	)
	stub(parser.parse).to_call(
		func(t: Array[Token]):
			return AST.Branch.new(-1, [], [], [])
	)
	stub(parser.get_errors).to_call(
		func():
			var errors: Array[Parser.ParseError] = [
				Parser.ParseError.new("foo", 5, 5),
			]
			return errors
	)
	var branch := doubled_branches[0]
	branch.changed.emit(3, "")

	assert_eq(sut._status.text, "foo")
	assert_not_called(model.update_branch)


func test_semantic_error() -> void:
	# Add branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(3))
	sut._on_add_branch_button_up()

	# Branch changes.
	stub(lexer.tokenize).to_call(
		func(s: String):
			var tokens: Array[Token] = []
			return tokens
	)
	var ast := AST.Branch.new(-1, [], [], [])
	stub(parser.parse).to_return(ast)
	stub(parser.get_errors).to_call(
		func():
			var errors: Array[Parser.ParseError] = []
			return errors
	)
	stub(visitor_iterator.is_valid).to_return(false)
	var branch := doubled_branches[0]
	branch.changed.emit(3, "")

	assert_eq(ast.id, 3, "AST should be set before visitors iterate")
	assert_not_called(model.update_branch)


func test_connecting_branch_to_existing_branch() -> void:
	# Add 1st branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(2))
	sut._on_add_branch_button_up()

	# Add 2nd branch.
	stub(model.add_branch).to_call(model.branch_added.emit.bind(4))
	sut._on_add_branch_button_up()

	# act.
	stub(model.has_branch).to_return(true)
	sut.connect_branches(2, [4])

	var from := doubled_branches[0]
	var to := doubled_branches[1]
	assert_true(sut._graph_edit.is_node_connected(from.name, 0, to.name, 0))
	assert_true(from.is_slot_enabled_right(0))
	assert_true(to.is_slot_enabled_left(0))


func test_connecting_branch_to_non_existing_branch() -> void:
	# Add branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(2))
	sut._on_add_branch_button_up()

	# act.
	stub(model.has_branch).when_passed(2).to_return(true)
	stub(model.has_branch).when_passed(7).to_return(false)
	stub(model.add_named_branch).to_call(model.branch_added.emit)
	sut.connect_branches(2, [7])

	var from := doubled_branches[0]
	var to := doubled_branches[1]
	assert_true(sut._graph_edit.is_node_connected(from.name, 0, to.name, 0))


func test_connecting_branch_to_non_existing_branch_offsets() -> void:
	# Add branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(2))
	sut._on_add_branch_button_up()

	# act.
	stub(model.has_branch).when_passed(2).to_return(true)
	stub(model.has_branch).when_passed(7).to_return(false)
	stub(model.add_named_branch).to_call(model.branch_added.emit)
	sut.connect_branches(2, [7])

	var from := doubled_branches[0]
	var to := doubled_branches[1]
	assert_gte(to.position_offset.x, from.position_offset.x + from.size.x)


func test_connect_branch_removes_previous_connections() -> void:
	# Add first branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(0))
	sut._on_add_branch_button_up()

	# Add second branch.
	stub(model.add_branch).to_call(model.branch_added.emit.bind(1))
	sut._on_add_branch_button_up()

	# Add third branch.
	stub(model.add_branch).to_call(model.branch_added.emit.bind(2))
	sut._on_add_branch_button_up()

	stub(model.has_branch).to_return(true)
	sut.connect_branches(0, [1])
	sut.connect_branches(0, [2])

	var first := doubled_branches[0]
	var second := doubled_branches[1]
	var third := doubled_branches[2]
	assert_true(sut._graph_edit.is_node_connected(first.name, 0, third.name, 0))
	assert_false(sut._graph_edit.is_node_connected(first.name, 0, second.name, 0))


func test_connect_branch_to_nothing_disables_slot() -> void:
	# Add first branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(0))
	sut._on_add_branch_button_up()

	# Add second branch.
	stub(model.add_branch).to_call(model.branch_added.emit.bind(1))
	sut._on_add_branch_button_up()

	# Add third branch.
	stub(model.add_branch).to_call(model.branch_added.emit.bind(2))
	sut._on_add_branch_button_up()

	stub(model.has_branch).to_return(true)
	sut.connect_branches(0, [1, 2])
	sut.connect_branches(0, [])

	var first := doubled_branches[0]
	var second := doubled_branches[1]
	var third := doubled_branches[2]
	assert_false(first.is_slot_enabled_right(0))
	assert_false(second.is_slot_enabled_left(0))
	assert_false(third.is_slot_enabled_left(0))


func test_remove_branch() -> void:
	# Add branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(0))
	sut._on_add_branch_button_up()

	sut._remove_branch(0)
	await wait_physics_frames(1)

	assert_eq(sut._branches.size(), 0)
	assert_eq(doubled_branches[0], null)
	assert_called(model.remove_branch)


func test_removing_branch_calls_set_text_on_left_connections() -> void:
	# Add first branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(0))
	sut._on_add_branch_button_up()

	# Add second branch.
	stub(model.add_branch).to_call(model.branch_added.emit.bind(1))
	sut._on_add_branch_button_up()
	var second_name := doubled_branches[1].name

	sut.connect_branches(0, [1])
	stub(model.get_branch).to_call(
		func(id: int):
			var ast := AST.Branch.new(0, [], [], [])
			return ast
	)

	sut._remove_branch(1)
	await wait_physics_frames(1)

	assert_called(unbranchers.iterate)
	assert_called(unparser.get_text)
	assert_called(doubled_branches[0].set_text)
	assert_false(sut._graph_edit.is_node_connected(doubled_branches[0].name, 0, second_name, 0))


func test_remove_branch_disables_previously_connected_empty_branch_slots() -> void:
	# Add first branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(0))
	sut._on_add_branch_button_up()

	# Add second branch.
	stub(model.add_branch).to_call(model.branch_added.emit.bind(1))
	sut._on_add_branch_button_up()

	# Add third branch.
	stub(model.add_branch).to_call(model.branch_added.emit.bind(2))
	sut._on_add_branch_button_up()

	sut.connect_branches(0, [1])
	sut.connect_branches(1, [2])

	stub(model.get_branch).to_call(
		func(id: int):
			var ast := AST.Branch.new(0, [], [], [])
			return ast
	)

	var first := doubled_branches[0]
	var third := doubled_branches[2]

	sut._remove_branch(1)
	await wait_physics_frames(1)

	assert_false(first.is_slot_enabled_right(0))
	assert_false(third.is_slot_enabled_left(0))


func test_switching_characters_removes_branch_nodes() -> void:
	# Add character.
	stub(model.get_branches).to_call(
		func():
			var branches: Dictionary[int, AST.Branch] = {}
			return branches
	)
	sut._on_add_character_button_up()
	var input_dialog := doubled_input_dialogs[0]
	input_dialog._on_done.call("fred")
	await wait_physics_frames(1)

	# Add branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(2))
	sut._on_add_branch_button_up()

	# Add second character.
	sut._on_add_character_button_up()
	input_dialog = doubled_input_dialogs[1]
	input_dialog._on_done.call("tom")
	await wait_physics_frames(1)

	assert_eq(sut._branches.size(), 0)


func test_switching_character_reconstructs_branch_nodes() -> void:
	# Add character.
	stub(model.get_branches).to_call(
		func():
			var branches: Dictionary[int, AST.Branch] = {
				0: AST.Branch.new(
					0,
					[],
					[
						AST.Prompt.new(
							[],
							AST.StringLiteral.new("foo"),
							[]
						),
					],
					[],
				),
				1: AST.Branch.new(
					1,
					[],
					[
						AST.Prompt.new(
							[],
							AST.StringLiteral.new("bar"),
							[]
						),
					],
					[],
				),
			}
			return branches
	)
	sut._on_add_character_button_up()
	var input_dialog := doubled_input_dialogs[0]
	input_dialog._on_done.call("tim")
	await wait_physics_frames(1)

	assert_eq(sut._branches.size(), 2)
	assert_called(visitor_iterator.iterate)
	assert_called(doubled_branches[0].set_text)
	assert_called(doubled_branches[1].set_text)


func test_switching_character_reconstructs_connections() -> void:
	# Add character.
	stub(model.get_branches).to_call(
		func():
			var branches: Dictionary[int, AST.Branch] = {
				0: AST.Branch.new(
					0,
					[],
					[
						AST.Prompt.new(
							[],
							AST.StringLiteral.new("foo"),
							[
								AST.Action.new(Global.CONNECT_BRANCH_KEYWORD, AST.NumberLiteral.new(1)),
							],
						),
					],
					[],
				),
				1: AST.Branch.new(
					1,
					[],
					[
						AST.Prompt.new(
							[],
							AST.StringLiteral.new("bar"),
							[],
						),
					],
					[],
				),
			}
			return branches
	)
	stub(visitor_iterator.iterate).to_call(
		func(ast: AST.ASTNode):
			sut.connect_branches(0, [1])
	)
	stub(model.has_branch).to_return(true)
	sut._on_add_character_button_up()
	var input_dialog := doubled_input_dialogs[0]
	input_dialog._on_done.call("tim")
	await wait_physics_frames(1)

	var from := doubled_branches[0]
	var to := doubled_branches[1]
	assert_true(sut._graph_edit.is_node_connected(from.name, 0, to.name, 0))


func test_switching_character_reconstructs_connections_to_empty_branches() -> void:
	stub(model.get_branches).to_call(
		func():
			var branches: Dictionary[int, AST.Branch] = {
				0: AST.Branch.new(
					0,
					[],
					[
						AST.Prompt.new(
							[],
							AST.StringLiteral.new("foo"),
							[
								AST.Action.new(Global.CONNECT_BRANCH_KEYWORD, AST.NumberLiteral.new(1)),
							],
						),
					],
					[],
				),
				1: AST.Branch.new(
					1,
					[],
					[],
					[],
				),
			}
			return branches
	)
	stub(visitor_iterator.iterate).to_call(
		func(ast: AST.ASTNode):
			sut.connect_branches(0, [1])
	)
	stub(model.has_branch).to_return(true)
	sut._on_add_character_button_up()
	var input_dialog := doubled_input_dialogs[0]
	input_dialog._on_done.call("fred")
	await wait_physics_frames(1)

	var from := doubled_branches[0]
	var to := doubled_branches[1]
	assert_true(sut._graph_edit.is_node_connected(from.name, 0, to.name, 0))


func test_err_branch() -> void:
	# Add branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(2))
	sut._on_add_branch_button_up()

	sut.err_branch(2, "foo")

	var branch := doubled_branches[0]
	assert_called(branch.color_invalid)
	assert_eq(sut._status.text, "foo")


func test_cannot_switch_character_with_errors() -> void:
	# Add branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(2))
	sut._on_add_branch_button_up()

	var branch := doubled_branches[0]
	stub(branch.is_erred).to_return(true)

	sut._on_tree_item_selected()

	assert_not_called(model.switch_character)


func test_save_project() -> void:
	# Press save project.
	stub(model.has_save_path).to_return(false)
	sut._on_save_project_button_up()
	var save_dialog := doubled_oasis_dialogs[0]
	save_dialog.selected.emit("to/path")
	await wait_physics_frames(1)

	assert_called(model, "set_save_path", ["to/path"])
	assert_called(model.save_project)


func test_save_project_canceled() -> void:
	# Press save project.
	stub(model.has_save_path).to_return(false)
	sut._on_save_project_button_up()
	var dialog := doubled_oasis_dialogs[0]
	dialog.canceled.emit()
	await wait_physics_frames(1)

	assert_not_called(model.save_project)


func test_save_project_with_save_path() -> void:
	# Press save project.
	stub(model.has_save_path).to_return(true)
	sut._on_save_project_button_up()

	assert_eq(doubled_oasis_dialogs.size(), 0)
	assert_called(model.save_project)


func test_load_project() -> void:
	# Press load project.
	sut._on_load_project_button_up()
	var dialog := doubled_oasis_dialogs[0]
	stub(model.load_project).to_return(true)
	stub(model.get_characters).to_call(
		func():
			return {
				"fred": {},
				"joe": {},
		}
	)
	dialog.selected.emit("to/path")
	await wait_physics_frames(1)

	assert_called(model, "load_project", ["to/path"])
	assert_eq(sut._character_tree.get_root().get_child_count(), 2)


func test_load_project_rewrites_tree() -> void:
	# Add character.
	sut._on_add_character_button_up()
	stub(model.get_branches).to_call(
		func():
			var branches: Dictionary[int, AST.Branch] = {}
			return branches
	)
	var input_dialog := doubled_input_dialogs[0]
	input_dialog._on_done.call("fred")
	await wait_physics_frames(1)

	# Add branch.
	stub(model.get_characters).to_call(
		func():
			var characters: Dictionary[String, AST.Character] = {
				"fred": AST.Character.new("fred", {}),
			}
			return characters
	)
	stub(model.get_active_character).to_return("fred")
	stub(model.add_branch).to_call(model.branch_added.emit.bind(0))
	sut._on_add_branch_button_up()

	# Press load project.
	sut._on_load_project_button_up()
	var dialog := doubled_oasis_dialogs[0]
	stub(model.load_project).to_return(true)
	stub(model.get_characters).to_call(
		func():
			return {
				"tim": {},
				"joe": {},
		}
	)
	dialog.selected.emit("to/path")
	await wait_physics_frames(1)

	assert_eq(sut._character_tree.get_root().get_child_count(), 2)


func test_load_project_canceled() -> void:
	# Press load project.
	sut._on_load_project_button_up()
	var dialog := doubled_oasis_dialogs[0]
	dialog.canceled.emit()
	await wait_physics_frames(1)

	assert_not_called(model.load_project)


func test_load_project_failed() -> void:
	# Press load project.
	sut._on_load_project_button_up()
	var dialog := doubled_oasis_dialogs[0]
	stub(model.load_project).to_return(false)
	dialog.selected.emit("to/path")
	await wait_physics_frames(1)

	assert_eq(sut._character_tree.get_root().get_child_count(), 0)

@tool
extends Control

const _Global := preload("res://addons/oasis_dialogue/global.gd")

const _AddCharacterButton := preload("res://addons/oasis_dialogue/canvas/add_character_button.gd")
const _RemoveCharacterButton := preload("res://addons/oasis_dialogue/canvas/remove_character_button.gd")
const _AddBranchButton := preload("res://addons/oasis_dialogue/canvas/add_branch_button.gd")
const _InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.tscn")
const _ConfirmDialog := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.tscn")
const _LanguageServer := preload("res://addons/oasis_dialogue/language_server.gd")

const _SemanticError := preload("res://addons/oasis_dialogue/semantic_error.gd")

const _Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const _BranchScene := preload("res://addons/oasis_dialogue/branch/branch.tscn")
const _BranchEdit := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _Highlighter := preload("res://addons/oasis_dialogue/branch/highlighter.gd")
const _Status := preload("res://addons/oasis_dialogue/canvas/status.gd")

const _CharacterTree := preload("res://addons/oasis_dialogue/canvas/character_tree.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/project_manager.gd")
const _RenameCharacterHandler := preload("res://addons/oasis_dialogue/rename_character_handler.gd")

const _Model := preload("res://addons/oasis_dialogue/model/model.gd")
const _Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")
const _Parser := preload("res://addons/oasis_dialogue/model/parser.gd")
const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _ParseError := preload("res://addons/oasis_dialogue/model/parse_error.gd")

const _ValidateConnectVisitor := preload("res://addons/oasis_dialogue/visitor/validate_connect_visitor.gd")
const _CreateBranchVisitor := preload("res://addons/oasis_dialogue/visitor/create_branch_visitor.gd")
const _ConnectBranchVisitor := preload("res://addons/oasis_dialogue/visitor/connect_branch_visitor.gd")
const _DuplicateAnnotationVisitor := preload("res://addons/oasis_dialogue/visitor/duplicate_annotation_visitor.gd")
const _EmptyBranchVisitor := preload("res://addons/oasis_dialogue/visitor/empty_branch_visitor.gd")
const _UpdateModelVisitor := preload("res://addons/oasis_dialogue/visitor/update_model_visitor.gd")
const _RemoveActionVisitor := preload("res://addons/oasis_dialogue/visitor/remove_action_visitor.gd")
const _FinishCallbackVisitor := preload("res://addons/oasis_dialogue/visitor/finish_callback_visitor.gd")
const _UnparserVisitor := preload("res://addons/oasis_dialogue/visitor/unparser_visitor.gd")
const _VisitorIterator := preload("res://addons/oasis_dialogue/visitor/visitor_iterator.gd")

var _model: _Model = null
var language_server:  _LanguageServer = null
var semantic_visitors: _VisitorIterator = null
var restore_branch_visitors: _VisitorIterator = null
var _rename_character_handler: _RenameCharacterHandler = null


func _ready() -> void:
	var tree: _CharacterTree = $VBoxContainer/SplitContainer/CharacterTree
	var graph: _BranchEdit = $VBoxContainer/SplitContainer/BranchEdit
	var add_branch: _AddBranchButton = $VBoxContainer/HeaderMarginContainer/HBoxContainer/AddBranch
	var add_character: _AddCharacterButton = $VBoxContainer/HeaderMarginContainer/HBoxContainer/AddCharacter
	var remove_character: _RemoveCharacterButton = $VBoxContainer/HeaderMarginContainer/HBoxContainer/RemoveCharacter
	var status: _Status = $VBoxContainer/FooterMarginContainer/Status

	var lexer := _Lexer.new()
	var parser := _Parser.new()

	var input_dialog_factory := func():
		var dialog: Control = _InputDialog.instantiate()
		add_child(dialog)
		return dialog
	var confirm_dialog_factory := func():
		var dialog: Control = _ConfirmDialog.instantiate()
		add_child(dialog)
		return dialog
	var branch_factory := func():
		var branch: _Branch = _BranchScene.instantiate()
		var highlighter := _Highlighter.new()
		highlighter.set_lexer(lexer)
		branch.init(highlighter)
		return branch

	var err_branch := func err_branch(e: _SemanticError) -> void:
		#var branch := graph.get_branch(id)
		#branch.color_invalid()
		status.err(e.message)
		graph.highlight_branch(e.id, [e.line])

	var parse_err_branch := func(e: _ParseError) -> void:
		graph.highlight_branch(e.id, [e.line])
		status.err(e.message)

	_model = _Model.new()
	language_server = _LanguageServer.new(lexer, parser)
	language_server.erred.connect(parse_err_branch)
	semantic_visitors = _VisitorIterator.new()
	restore_branch_visitors = _VisitorIterator.new()
	_rename_character_handler = _RenameCharacterHandler.new()

	_rename_character_handler.get_active_character = _model.get_active_character
	_rename_character_handler.input_dialog_factory = input_dialog_factory
	_rename_character_handler.character_renamed.connect(tree.edit_selected_item)

	var duplicate_annotation_visitor := _DuplicateAnnotationVisitor.new(semantic_visitors.stop)
	duplicate_annotation_visitor.erred.connect(err_branch)
	var update_model_visitor := _UpdateModelVisitor.new(_model)
	var unparser_visitor := _UnparserVisitor.new(graph)
	var validate_connect_visitor := _ValidateConnectVisitor.new(
		_Global.CONNECT_BRANCH_KEYWORD,
		semantic_visitors.stop,
	)
	validate_connect_visitor.erred.connect(err_branch)
	var create_branch_visitor := _CreateBranchVisitor.new(
		_Global.CONNECT_BRANCH_KEYWORD,
		_model,
		graph,
	)
	var connect_branch_visitor := _ConnectBranchVisitor.new(
		_Global.CONNECT_BRANCH_KEYWORD,
		graph.connect_branches,
	)
	var clear_status_err := _FinishCallbackVisitor.new(status.clear_err.unbind(1))
	var clear_branch_highlights_visitor := _FinishCallbackVisitor.new(graph.clear_branch_highlights)

	#CREATE ERROR HANDLER THAT RECEIVES SEMANTIC ERRORS
	#TELLS STATUS AND GRAPH

	add_branch.init(_model)
	add_branch.branch_added.connect(_model.add_branch)
	add_branch.branch_added.connect(graph.add_branch)

	add_character.init(_model, input_dialog_factory)
	add_character.character_added.connect(tree.add_item)
	add_character.character_added.connect(_model.add_character)

	remove_character.init(_model, confirm_dialog_factory)
	remove_character.character_removed.connect(tree.remove_selected_item)
	remove_character.character_removed.connect(_model.remove_active_character)
	remove_character.character_removed.connect(graph.remove_branches)
	remove_character.character_removed.connect(add_branch.hide)
	remove_character.character_removed.connect(remove_character.hide)

	tree.character_activated.connect(_rename_character_handler.rename)

	graph.init(branch_factory)
	graph.branch_added.connect(
		func connect_branch_to_language_server(branch: _Branch) -> void:
			branch.changed.connect(language_server.parse_branch_text)
	)

	language_server.parsed.connect(semantic_visitors.iterate)

	semantic_visitors.set_visitors([
		duplicate_annotation_visitor,
		validate_connect_visitor,
		create_branch_visitor,
		connect_branch_visitor,
		update_model_visitor,
		clear_branch_highlights_visitor,
		clear_status_err,
	])

	# Visitors to handle removal of text in affected branches after a branch
	# is removed needs to be created on demand.
	# Refactor this to BranchRemovalCleaner
	var unbranch_removed := func unbranch_from_deleted(removed_id: int, dirty_ids: Array[int]) -> void:
		var visitors := _VisitorIterator.new()
		visitors.set_visitors([
			_RemoveActionVisitor.new(
				_AST.Action.new(
					_Global.CONNECT_BRANCH_KEYWORD,
					_AST.NumberLiteral.new(removed_id)
				)
			),
			update_model_visitor,
			unparser_visitor,
		])

		for id in dirty_ids:
			var ast := _model.get_branch(id)
			visitors.iterate(ast)
		_model.remove_branch(removed_id)
	graph.branches_dirtied.connect(unbranch_removed)

	# Refactor to BranchReconstructor
	var restore_branch := func restore_branches(id: int) -> void:
		var ast := _model.get_branch(id)
		restore_branch_visitors.iterate(ast)
	graph.branch_restored.connect(restore_branch)

	restore_branch_visitors.set_visitors([
		unparser_visitor,
	])


func init(manager: _ProjectManager) -> void:
	var graph: _BranchEdit = $VBoxContainer/SplitContainer/BranchEdit
	var tree: _CharacterTree = $VBoxContainer/SplitContainer/CharacterTree

	manager.file_loaded.connect(_model.load_character)
	manager.file_loaded.connect(graph.load_character)
	manager.project_loaded.connect(tree.load_project)
	manager.project_loaded.connect(_model.load_project)
	manager.saving_file.connect(_model.save_character)
	manager.saving_file.connect(graph.save_character)
	manager.saving_project.connect(_model.save_project)

	var add_branch: _AddBranchButton = $VBoxContainer/HeaderMarginContainer/HBoxContainer/AddBranch
	manager.file_loaded.connect(add_branch.show.unbind(1))

	var add_character: _AddCharacterButton = $VBoxContainer/HeaderMarginContainer/HBoxContainer/AddCharacter
	add_character.character_added.connect(manager.add_subfile)

	var remove_character: _RemoveCharacterButton = $VBoxContainer/HeaderMarginContainer/HBoxContainer/RemoveCharacter
	remove_character.character_removed.connect(manager.remove_active_subfile)
	manager.file_loaded.connect(remove_character.show.unbind(1))

	tree.character_selected.connect(manager.load_subfile)

	_rename_character_handler.can_rename_to = manager.can_rename_active_to
	_rename_character_handler.character_renamed.connect(manager.rename_active_subfile)

@tool
extends Control

# const CONNECT_BRANCH_KEYWORD := "branch"

const _Global := preload("res://addons/oasis_dialogue/global.gd")
# const _CanvasInit := preload("res://addons/oasis_dialogue/canvas/canvas_init.gd")
# const _Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
# const _ConfirmDialog := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.gd")

const _AddCharacterButton := preload("res://addons/oasis_dialogue/buttons/add_character_button.gd")
const _RemoveCharacterButton := preload("res://addons/oasis_dialogue/buttons/remove_character_button.gd")
const _AddBranchButton := preload("res://addons/oasis_dialogue/buttons/add_branch_button.gd")
const _InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.tscn")
const _ConfirmDialog := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.tscn")
const _LanguageServer := preload("res://addons/oasis_dialogue/language_server.gd")

const _Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const _BranchScene := preload("res://addons/oasis_dialogue/branch/branch.tscn")
const _BranchEdit := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _Highlighter := preload("res://addons/oasis_dialogue/branch/highlighter.gd")

const _CharacterTree := preload("res://addons/oasis_dialogue/character_tree.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/project_manager.gd")
const _RenameCharacterHandler := preload("res://addons/oasis_dialogue/rename_character_handler.gd")

# const _OasisDialog := preload("res://addons/oasis_dialogue/file_dialog/oasis_dialog.gd")
const _Model := preload("res://addons/oasis_dialogue/model/model.gd")
const _Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")
const _Parser := preload("res://addons/oasis_dialogue/model/parser.gd")
# const _SequenceUtils := preload("res://addons/oasis_dialogue/utils/sequence.gd")
const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _UnparserVisitor := preload("res://addons/oasis_dialogue/visitor/unparser_visitor.gd")
const _VisitorIterator := preload("res://addons/oasis_dialogue/visitor/visitor_iterator.gd")
const _VisitorIteratorNode := preload("res://addons/oasis_dialogue/visitor_iterator_node.gd")

const _Unparser := preload("res://addons/oasis_dialogue/unparser.gd")
const _Unbrancher := preload("res://addons/oasis_dialogue/unbrancher.gd")
# const _GraphController := preload("res://addons/oasis_dialogue/canvas/graph_controller.gd")

const _ConnectBranchVisitor := preload("res://addons/oasis_dialogue/visitor/connect_branch_visitor.gd")
const _DuplicateAnnotationVisitor := preload("res://addons/oasis_dialogue/visitor/duplicate_annotation_visitor.gd")
const _EmptyBranchVisitor := preload("res://addons/oasis_dialogue/visitor/empty_branch_visitor.gd")
const _UpdateModelVisitor := preload("res://addons/oasis_dialogue/visitor/update_model_visitor.gd")
const _RemoveActionVisitor := preload("res://addons/oasis_dialogue/visitor/remove_action_visitor.gd")


func _ready() -> void:
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

	var model: _Model = $Model
	var tree: _CharacterTree = $VBoxContainer/SplitContainer/CharacterTree
	var graph: _BranchEdit = $VBoxContainer/SplitContainer/BranchEdit
	graph.init(branch_factory)


	var semantic_visitors: _VisitorIteratorNode = $SemanticVisitors
	var language_server: _LanguageServer = $LanguageServer

	# keep!
	language_server.init(lexer, parser)
	graph.branch_added.connect(
		func(id: int, branch: _Branch):
			branch.changed.connect(language_server.parse_branch_text)
	)
	language_server.parsed.connect(semantic_visitors.iterate)
	# endkeep
	#keep
	#var empty_branch_visitor := _EmptyBranchVisitor.new(
		#semantic_visitors.stop,
		#err_branch
	#)
	#var duplicate_annotation_visitor := _DuplicateAnnotationVisitor.new(
		#semantic_visitors.stop,
		#err_branch,
	#)
	#var connect_branch_visitor := _ConnectBranchVisitor.new(
		#_Global.CONNECT_BRANCH_KEYWORD,
		#graph.connect_branches,
		#err_branch,
	#)
	#var update_model_visitor := _UpdateModelVisitor.new(
		#model,
	#)
	#semantic_visitors.set_visitors([
		#empty_branch_visitor,
		#duplicate_annotation_visitor,
		#connect_branch_visitor,
		#update_model_visitor,
	#])
	##endkeep
#
	#var unbrancher_factory := func(id: int):
		#var visitors := _VisitorIterator.new()
		#visitors.set_visitors([
			#_RemoveActionVisitor.new(
				#_AST.Action.new(
					#_Global.CONNECT_BRANCH_KEYWORD,
					#_AST.NumberLiteral.new(id),
				#),
			#),
		#])
		#return visitors

	#var unbrancher: _Unbrancher = $Unbrancher
	#unbrancher.init(unbrancher_factory)
	#graph.branches_dirtied.connect(unbrancher.clean_branches)
#
	#var unparser: _Unparser = $Unparser
	#unparser.init(_UnparserVisitor.new())
	#unbrancher.unparse_requested.connect(unparser.unparse)
	#graph.branch_restored.connect(unparser.unparse)


func init(manager: _ProjectManager) -> void:
	var model: _Model = $Model
	var graph: _BranchEdit = $VBoxContainer/SplitContainer/BranchEdit
	var tree: _CharacterTree = $VBoxContainer/SplitContainer/CharacterTree

	manager.file_loaded.connect(model.load_character)
	manager.file_loaded.connect(graph.load_character)
	manager.project_loaded.connect(tree.load_project)
	manager.project_loaded.connect(model.load_project)
	manager.saving_file.connect(model.save_character)
	manager.saving_file.connect(graph.save_character)
	manager.saving_project.connect(model.save_project)

	var remove_character: _RemoveCharacterButton = $VBoxContainer/HeaderMarginContainer/HBoxContainer/RemoveCharacter
	remove_character.character_removed.connect(manager.remove_active_subfile)

	var add_character: _AddCharacterButton = $VBoxContainer/HeaderMarginContainer/HBoxContainer/AddCharacter
	add_character.character_added.connect(manager.add_subfile)

	var rename_handler: _RenameCharacterHandler = $RenameCharacterHandler
	rename_handler.character_renamed.connect(manager.rename_active_subfile)


func err_branch() -> void:
	pass

# var _lexer: _Lexer = null
# var _parser: _Parser = null
# var _unparser: _Unparser = null
# var _visitors: _VisitorIterator = null
# var _graph_controller: _GraphController = null
# [code]func() -> _Branch[/code]
# var _branch_factory := Callable()
# [code]func() -> InputDialogFactory[/code]
# var _input_dialog_factory := Callable()
# [code]func() -> ConfirmDialogFactory[/code]
# var _confirm_dialog_factory := Callable()
# [code]func(id: int) -> VisitorIterator[/code]
# var _unbranchers_factory := Callable()
# [code]func() -> OasisDialog[/code]
# var _save_dialog_factory := Callable()
# [code]func() -> OasisDialog[/code]
# var _load_dialog_factory := Callable()


# func init(init: _CanvasInit) -> void:
	# _model = init.model
	# _model.branch_added.connect(_add_branch)
	# _lexer = init.lexer
	# _parser = init.parser
	# _unparser = init.unparser
	# _visitors = init.visitors
	# _branch_factory = init.branch_factory
	# _input_dialog_factory = init.input_dialog_factory
	# _confirm_dialog_factory = init.confirm_dialog_factory
	# _unbranchers_factory = init.unbranchers_factory
	# _save_dialog_factory = init.save_dialog_factory
	# _load_dialog_factory = init.load_dialog_factory
	# _graph_controller = init.graph_controller


# func err_branch(id: int, message: String) -> void:
	# var branch := _branches[id]
	# branch.color_invalid()
	# _update_status(message, _Duration.INF)


# func _on_add_branch_button_up() -> void:
	# if _model.get_characters().size() == 0:
		# _update_status("Please add a character first.", _Duration.SHORT)
		# return

	# if not _model.get_active_character():
		# _update_status("Please select a character.", _Duration.SHORT)
		# return

	# _model.add_branch()


# func _add_branch(id: int) -> void:
	# var branch: _Branch = _branch_factory.call()
	# _graph_edit.add_child(branch)
	# branch.set_on_remove(_remove_branch.bind(id))
	# branch.set_id(id)
	# branch.changed.connect(_on_branch_changed)
	# _graph_controller.center_node_in_graph(branch, _graph_edit)

	# _branches[id] = branch
	# _update_status("Added branch: %d." % id, _Duration.SHORT)


# func _on_branch_changed(id: int, text: String) -> void:
	# var tokens := _lexer.tokenize(text)
	# var ast := _parser.parse(tokens)
	# var errors := _parser.get_errors()

	# var error_lines: Array[int] = []
	# error_lines.assign(errors.map(func(e: _Parser.ParseError): return e.line))
	# var branch := _branches[id]
	# branch.highlight(error_lines)
	# branch.color_normal()

	# if errors:
		# _update_status(errors[0].message, _Duration.INF) # change to take a list.
		# return

	# (ast as _AST.Branch).id = id
	# _visitors.iterate(ast)
	# if not _visitors.is_valid():
		# return

	# _model.update_branch(id, ast)
	# _update_status("", _Duration.INF)


# func _on_add_character_button_up() -> void:
	# var input_dialog: _InputDialog = _input_dialog_factory.call()
	# add_child(input_dialog)
	# input_dialog.set_placeholder_text("Enter character name...")
	# input_dialog.set_validation(_validate_new_character)
	# input_dialog.set_on_cancel(_on_input_dialog_cancel.bind(input_dialog))
	# input_dialog.set_on_done(_on_input_dialog_done.bind(input_dialog))


# func _on_input_dialog_cancel(input_dialog: Control) -> void:
	# input_dialog.queue_free()
	# remove_child(input_dialog)


# func _on_input_dialog_done(name: String, input_dialog: Control) -> void:
	# input_dialog.queue_free()
	# remove_child(input_dialog)

	# _model.add_character(name)
	# _model.switch_character(name)

	# var item := _add_tree_item(name)
	# item.select(0)
	# _update_status("Added %s." % name, _Duration.SHORT)


# func _validate_new_character(name: String) -> String:
	# var message := ""
	# if name == "":
		# message = "Character cannot be a blank."
	# elif _model.has_character(name):
		# message = "%s already exists." % name
	# return message


# func _on_tree_item_selected() -> void:
	# if _branches.values().any(func(b: _Branch): return b.is_erred()):
		# return

	# _remove_all_branch_nodes()

	# var selected_name := _get_selected_tree_item_value()
	# _model.switch_character(selected_name)

	# var model_branches := _model.get_branches()
	# for id in model_branches:
		# _add_branch(id)
		# var ast := model_branches[id]
		# ast.accept(_unparser)

		# var branch := _branches[id]
		# branch.set_text(_unparser.get_text())
		# _unparser.finish()

	# model_branches.values().map(func(ast: _AST.ASTNode): _visitors.iterate(ast))
	# push_warning("todo arrange nodes")
	# _graph_controller.arrange_nodes(_branches.values(), _graph_edit)


# func _on_remove_character_button_up() -> void:
	# if _model.get_branches().size() > 0:
		# var confirm_dialog: _ConfirmDialog = _confirm_dialog_factory.call()
		# add_child(confirm_dialog)
		# var character := _model.get_active_character()
		# confirm_dialog.set_message("%s has _branches. Are you sure you want to remove %s" % [character, character])
		# confirm_dialog.set_on_cancel("cancel", _on_remove_character_cancel.bind(confirm_dialog))
		# confirm_dialog.set_on_confirm("delete", _remove_character.bind(confirm_dialog))
	# else:
		# _remove_character()


# func _on_remove_character_cancel(confirm_dialog: Control) -> void:
	# confirm_dialog.queue_free()
	# remove_child(confirm_dialog)


# func _remove_character(confirm_dialog: Control = null) -> void:
	# if confirm_dialog:
		# confirm_dialog.queue_free()
		# remove_child(confirm_dialog)

	# var removed_character := _model.get_active_character()
	# _model.remove_character(true)
	# _remove_selected_tree_item()
	# _remove_all_branch_nodes()
	# _update_status("Removed %s." % removed_character, _Duration.SHORT)


# func _on_save_project_button_up() -> void:
	# if not _model.has_save_path():
		# var save_dialog: _OasisDialog = _save_dialog_factory.call()
		# add_child(save_dialog)
		# save_dialog.selected.connect(_on_save_dialog_selected.bind(save_dialog))
		# save_dialog.canceled.connect(_on_save_dialog_canceled.bind(save_dialog))
	# else:
		# _save_project()


# func _on_save_dialog_selected(path: String, dialog: _OasisDialog) -> void:
	# remove_child(dialog)
	# dialog.queue_free()
	# _model.set_save_path(path)
	# _save_project()


# func _on_save_dialog_canceled(save_dialog: _OasisDialog) -> void:
	# remove_child(save_dialog)
	# save_dialog.queue_free()


# func _save_project() -> void:
	# var message := ""
	# if _model.save_project():
		# message = "Project saved to %s." % _model.get_save_path()
	# else:
		# message = "Something went wrong. Couldn't save the project."
	# _update_status(message, _Duration.SHORT)


# func _on_load_project_button_up() -> void:
	# var dialog := _load_dialog_factory.call()
	# add_child(dialog)
	# dialog.selected.connect(_on_load_dialog_selected.bind(dialog))
	# dialog.canceled.connect(_on_load_dialog_canceled.bind(dialog))


# func _on_load_dialog_selected(path: String, dialog: _OasisDialog) -> void:
	# remove_child(dialog)
	# dialog.queue_free()

	# if not _model.load_project(path):
		# _update_status("Could not load %s." % path.get_file(), _Duration.SHORT)
		# return

	# _remove_all_branch_nodes()
	# _clear_character_tree()
	# for name in _model.get_characters().keys():
		# _add_tree_item(name)


# func _on_load_dialog_canceled(dialog: _OasisDialog) -> void:
	# remove_child(dialog)
	# dialog.queue_free()


# func _update_status(message: String, duration: _Duration) -> void:
	# _status.text = message
	# if duration > -1:
		# %StatusTimer.start(duration)
	# else:
		# %StatusTimer.stop()


# func _on_status_timer_timeout() -> void:
	# _update_status("", _Duration.INF)


# func _edit_selected_tree_item(value: String) -> void:
	# var item := _character_tree.get_selected()
	# item.set_text(0, value)


# func _clear_character_tree() -> void:
	# _character_tree.get_root().get_children().map(func(t: TreeItem): t.free())


# func _remove_all_branch_nodes() -> void:
	# for branch in _branches.values():
		# branch.queue_free()
		# _graph_edit.remove_child(branch)
	# _branches.clear()

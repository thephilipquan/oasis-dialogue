@tool
extends Control

const CONNECT_BRANCH_KEYWORD := "branch"

const _CanvasInit := preload("res://addons/oasis_dialogue/canvas/canvas_init.gd")
const _Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const _ConfirmDialog := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.gd")
const _InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.gd")
const _Model := preload("res://addons/oasis_dialogue/model/model.gd")
const _Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")
const _Parser := preload("res://addons/oasis_dialogue/model/parser.gd")
const _SequenceUtils := preload("res://addons/oasis_dialogue/utils/sequence.gd")
const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Unparser := preload("res://addons/oasis_dialogue/model/unparser_visitor.gd")
const _VisitorIterator := preload("res://addons/oasis_dialogue/model/visitor_iterator.gd")
const _GraphUtils := preload("res://addons/oasis_dialogue/utils/graph_edit_utils.gd")


@onready
var _character_tree: Tree = %Tree
@onready
var _graph_edit: GraphEdit = %GraphEdit
@onready
var _status := $VBoxContainer/FooterMarginContainer/Status

var _model: _Model = null
var _branches: Dictionary[int, _Branch] = {}

var _lexer: _Lexer = null
var _parser: _Parser = null
var _unparser: _Unparser = null
var _visitors: _VisitorIterator = null
## [code]func() -> _Branch[/code]
var _branch_factory := Callable()
## [code]func() -> InputDialogFactory[/code]
var _input_dialog_factory := Callable()
## [code]func() -> ConfirmDialogFactory[/code]
var _confirm_dialog_factory := Callable()
## [code]func(id: int) -> VisitorIterator[/code]
var _unbranchers_factory := Callable()
## [code]func() -> SaveDialog[/code]
var _save_dialog_factory := Callable()
## [code]func() -> void[/code]
var _save_project := Callable()


func _ready() -> void:
	_add_tree_item("root")


func init(init: _CanvasInit) -> void:
	_model = init.model
	_model.branch_added.connect(_add_branch)
	_lexer = init.lexer
	_parser = init.parser
	_unparser = init.unparser
	_visitors = init.visitors
	_branch_factory = init.branch_factory
	_input_dialog_factory = init.input_dialog_factory
	_confirm_dialog_factory = init.confirm_dialog_factory
	_unbranchers_factory = init.unbranchers_factory


func err_branch(id: int, message: String) -> void:
	var branch := _branches[id]
	branch.color_invalid()
	_update_status(message)


func connect_branches(from_id: int, to_ids: Array[int]) -> void:
	for to_id in to_ids:
		if not _model.has_branch(to_id):
			_model.add_named_branch(to_id)

	var disconnected_branches: Array[GraphNode] = []
	var from := _branches[from_id]
	from.set_slot_enabled_right(0, to_ids.size())
	for other in _branches.keys():
		var to := _branches[other]
		var is_in := to_ids.has(other)
		var is_connected := _graph_edit.is_node_connected(from.name, 0, to.name, 0)
		if is_in and not is_connected:
			if not to.is_slot_enabled_left(0):
				to.set_slot_enabled_left(0, true)
			_graph_edit.connect_node(from.name, 0, to.name, 0)
		elif not is_in and is_connected:
			_graph_edit.disconnect_node(from.name, 0, to.name, 0)
			disconnected_branches.push_back(to)

	_GraphUtils.arrange_nodes(_branches.values(), _graph_edit)
	_GraphUtils.disable_left_with_no_connections(disconnected_branches, _graph_edit)


func _on_add_branch_button_up() -> void:
	if _model.get_characters().size() == 0:
		_update_status("Please add a character first.")
		return

	if not _model.get_active_character():
		_update_status("Please select a character.")
		return

	_model.add_branch()


func _add_branch(id: int) -> void:
	var branch: _Branch = _branch_factory.call()
	_graph_edit.add_child(branch)
	branch.set_on_remove(_remove_branch.bind(id))
	branch.set_id(id)
	branch.changed.connect(_on_branch_changed)
	branch.position_offset = (_graph_edit.size / 2 + _graph_edit.scroll_offset) / _graph_edit.zoom - branch.size / 2

	_branches[id] = branch


func _remove_branch(id: int) -> void:
	var branch := _branches[id]

	var unbrancher: _VisitorIterator = _unbranchers_factory.call(id)
	var disconnected_branches: Array[GraphNode] = []
	for other_id in _branches:
		var other := _branches[other_id]
		if other == branch:
			continue
		if _graph_edit.is_node_connected(other.name, 0, branch.name, 0):
			var ast := _model.get_branch(other_id)
			unbrancher.iterate(ast)
			ast.accept(_unparser)
			other.set_text(_unparser.get_text())
			_unparser.finish()
			_graph_edit.disconnect_node(other.name, 0, branch.name, 0)
			disconnected_branches.push_back(other)
		if _graph_edit.is_node_connected(branch.name, 0, other.name, 0):
			_graph_edit.disconnect_node(branch.name, 0, other.name, 0)
			disconnected_branches.push_back(other)

	_GraphUtils.disable_slots_of_non_connecting(disconnected_branches, _graph_edit)
	_branches.erase(id)
	_model.remove_branch(id)
	_graph_edit.remove_child(branch)
	branch.queue_free()


func _on_branch_changed(id: int, text: String) -> void:
	var tokens := _lexer.tokenize(text)
	var ast := _parser.parse(tokens)
	var errors := _parser.get_errors()

	var error_lines: Array[int] = []
	error_lines.assign(errors.map(func(e: _Parser.ParseError): return e.line))
	var branch := _branches[id]
	branch.highlight(error_lines)
	branch.color_normal()

	if errors:
		_update_status(errors[0].message) # change to take a list.
		return

	(ast as _AST.Branch).id = id
	_visitors.iterate(ast)
	if not _visitors.is_valid():
		return

	_model.update_branch(id, ast)


func _on_add_character_button_up() -> void:
	var input_dialog: _InputDialog = _input_dialog_factory.call()
	add_child(input_dialog)
	input_dialog.set_placeholder_text("Enter character name...")
	input_dialog.set_validation(_validate_new_character)
	input_dialog.set_on_cancel(_on_input_dialog_cancel.bind(input_dialog))
	input_dialog.set_on_done(_on_input_dialog_done.bind(input_dialog))


func _on_input_dialog_cancel(input_dialog: Control) -> void:
	input_dialog.queue_free()
	remove_child(input_dialog)


func _on_input_dialog_done(name: String, input_dialog: Control) -> void:
	input_dialog.queue_free()
	remove_child(input_dialog)

	_model.add_character(name)
	_model.switch_character(name)

	var item := _add_tree_item(name)
	item.select(0)


func _validate_new_character(name: String) -> String:
	var message := ""
	if name == "":
		message = "Character cannot be a blank."
	elif _model.has_character(name):
		message = "%s already exists." % name
	return message


func _on_tree_item_selected() -> void:
	if _branches.values().any(func(b: _Branch): return b.is_erred()):
		return

	_remove_all_branch_nodes()

	var selected_name := _get_selected_tree_item_value()
	_model.switch_character(selected_name)

	var model_branches := _model.get_branches()
	for id in model_branches:
		_add_branch(id)
		var ast := model_branches[id]
		ast.accept(_unparser)

		var branch := _branches[id]
		branch.set_text(_unparser.get_text())
		_unparser.finish()

	model_branches.values().map(func(ast: _AST.ASTNode): _visitors.iterate(ast))
	_GraphUtils.arrange_nodes(_branches.values(), _graph_edit)


func _on_tree_item_activated() -> void:
	var input_dialog: _InputDialog = _input_dialog_factory.call()
	add_child(input_dialog)
	input_dialog.set_placeholder_text("Renaming %s to..." % _model.get_active_character())
	input_dialog.set_validation(_validate_rename.bind(_model.get_characters().keys()))
	input_dialog.set_on_done(_on_input_dialog_rename_done.bind(input_dialog))
	input_dialog.set_on_cancel(_on_input_dialog_rename_cancel.bind(input_dialog))


func _on_input_dialog_rename_done(new_name: String, input_dialog: Control) -> void:
	input_dialog.queue_free()
	remove_child(input_dialog)

	var old_name := _model.get_active_character()
	if old_name == new_name or new_name == "":
		return

	_model.rename_character(new_name)
	_edit_selected_tree_item(_model.get_active_character())


func _validate_rename(name: String, characters: Array[String]) -> String:
	var message := ""
	if name in characters:
		message = "%s already exists." % name
	return message


func _on_input_dialog_rename_cancel(input_dialog: Control) -> void:
	input_dialog.queue_free()
	remove_child(input_dialog)


func _on_remove_character_button_up() -> void:
	if _model.get_branches().size() > 0:
		var confirm_dialog: _ConfirmDialog = _confirm_dialog_factory.call()
		add_child(confirm_dialog)
		var character := _model.get_active_character()
		confirm_dialog.set_message("%s has _branches. Are you sure you want to remove %s" % [character, character])
		confirm_dialog.set_on_cancel("cancel", _on_remove_character_cancel.bind(confirm_dialog))
		confirm_dialog.set_on_confirm("delete", _remove_character.bind(confirm_dialog))
	else:
		_remove_character()


func _on_remove_character_cancel(confirm_dialog: Control) -> void:
	confirm_dialog.queue_free()
	remove_child(confirm_dialog)


func _remove_character(confirm_dialog: Control = null) -> void:
	if confirm_dialog:
		confirm_dialog.queue_free()
		remove_child(confirm_dialog)

	_model.remove_character()
	_remove_selected_tree_item()
	_remove_all_branch_nodes()


func _update_status(message: String, duration := -1) -> void:
	_status.text = message
	if duration > -1:
		%StatusTimer.start(duration)
	else:
		%StatusTimer.stop()


func _on_status_timer_timeout() -> void:
	_update_status("")


func _add_tree_item(value: String) -> TreeItem:
	var item := _character_tree.create_item()
	item.set_text(0, value)
	return item


func _remove_selected_tree_item() -> void:
	_character_tree.get_selected().free()


func _get_selected_tree_item_value() -> String:
	return _character_tree.get_selected().get_text(0)


func _edit_selected_tree_item(value: String) -> void:
	var item := _character_tree.get_selected()
	item.set_text(0, value)


func _remove_all_branch_nodes() -> void:
	for branch in _branches.values():
		branch.queue_free()
		_graph_edit.remove_child(branch)
	_branches.clear()

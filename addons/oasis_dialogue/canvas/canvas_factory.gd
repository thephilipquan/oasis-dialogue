extends RefCounted

const _Global := preload("res://addons/oasis_dialogue/global.gd")

const _Canvas := preload("res://addons/oasis_dialogue/canvas/canvas.gd")
const _CanvasScene := preload("res://addons/oasis_dialogue/canvas/canvas.tscn")
const _CanvasInit := preload("res://addons/oasis_dialogue/canvas/canvas_init.gd")

const _Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const _BranchScene := preload("res://addons/oasis_dialogue/branch/branch.tscn")

const _InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.gd")
const _InputDialogScene := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.tscn")

const _ConfirmDialog := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.gd")
const _ConfirmDialogScene := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.tscn")

const _OasisDialog := preload("res://addons/oasis_dialogue/file_dialog/oasis_dialog.gd")

const _Model := preload("res://addons/oasis_dialogue/model/model.gd")
const _Unparser := preload("res://addons/oasis_dialogue/model/unparser_visitor.gd")
const _Parser := preload("res://addons/oasis_dialogue/model/parser.gd")
const _Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")
const _BranchHighlighter := preload("res://addons/oasis_dialogue/branch/highlighter.gd")
const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")

const _Visitor := preload("res://addons/oasis_dialogue/model/visitor.gd")
const _ActionExistsVisitor := preload("res://addons/oasis_dialogue/model/action_exists_visitor.gd")
const _ConditionExistsVisitor := preload("res://addons/oasis_dialogue/model/condition_exists_visitor.gd")
const _ConnectBranchVisitor := preload("res://addons/oasis_dialogue/model/connect_branch_visitor.gd")
const _DuplicateAnnotationVisitor := preload("res://addons/oasis_dialogue/model/duplicate_annotation_visitor.gd")
const _EmptyBranchVisitor := preload("res://addons/oasis_dialogue/model/empty_branch_visitor.gd")
const _RemoveActionVisitor := preload("res://addons/oasis_dialogue/model/remove_action_visitor.gd")
const _VisitorIterator := preload("res://addons/oasis_dialogue/model/visitor_iterator.gd")


static func create() -> _Canvas:
	var canvas := _CanvasScene.instantiate()
	var model := _Model.new()
	model.set_actions([_Global.CONNECT_BRANCH_KEYWORD])

	var visitor_iterator := _VisitorIterator.new()
	var empty_branch_visitor := _EmptyBranchVisitor.new(
		visitor_iterator.stop,
		canvas.err_branch
	)
	var duplicate_annotation_visitor := _DuplicateAnnotationVisitor.new(
		visitor_iterator.stop,
		canvas.err_branch,
	)
	#var action_exists_visitor := _ActionExistsVisitor.new(
		#model.has_action,
		#canvas.err_branch,
	#)
	#var condition_exists_visitor := _ConditionExistsVisitor.new(
		#model.has_condition,
		#canvas.err_branch,
	#)
	var connect_branch_visitor := _ConnectBranchVisitor.new(
		_Global.CONNECT_BRANCH_KEYWORD,
		canvas.connect_branches,
		canvas.err_branch,
	)

	visitor_iterator.set_visitors([
		empty_branch_visitor,
		duplicate_annotation_visitor,
		#action_exists_visitor,
		#condition_exists_visitor,
		connect_branch_visitor,
	])

	var lexer := _Lexer.new()
	var branch_factory := func():
		var branch: _Branch = _BranchScene.instantiate()
		var highlighter := _BranchHighlighter.new()
		highlighter.set_lexer(lexer)
		branch.init(highlighter)
		return branch
	var input_dialog_factory := func():
		var input_dialog: _InputDialog = _InputDialogScene.instantiate()
		return input_dialog
	var confirm_dialog_factory := func():
		var confirm_dialog: _ConfirmDialog = _ConfirmDialogScene.instantiate()
		return confirm_dialog
	var unbranchers_factory := func(id: int):
		var iterator := _VisitorIterator.new()
		iterator.set_visitors([
			_RemoveActionVisitor.new(
				_AST.Action.new(
					_Global.CONNECT_BRANCH_KEYWORD,
					_AST.NumberLiteral.new(id),
				)
			),
		])
		return iterator

	var save_dialog_factory := func():
		var oasis_dialog := _OasisDialog.new()
		oasis_dialog.init(FileDialog.FILE_MODE_SAVE_FILE)
		return oasis_dialog
	var load_dialog_factory := func():
		var dialog := _OasisDialog.new()
		dialog.init(FileDialog.FILE_MODE_OPEN_FILE)
		return dialog

	var init := _CanvasInit.new()
	init.model = model
	init.lexer = lexer
	init.parser = _Parser.new()
	init.unparser = _Unparser.new()
	init.visitors = visitor_iterator
	init.branch_factory = branch_factory
	init.input_dialog_factory = input_dialog_factory
	init.confirm_dialog_factory = confirm_dialog_factory
	init.unbranchers_factory = unbranchers_factory
	init.save_dialog_factory = save_dialog_factory
	init.load_dialog_factory = load_dialog_factory
	canvas.init(init)
	return canvas

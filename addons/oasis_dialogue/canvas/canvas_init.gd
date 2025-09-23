extends RefCounted

const _Model := preload("res://addons/oasis_dialogue/model/model.gd")
const _Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")
const _Parser := preload("res://addons/oasis_dialogue/model/parser.gd")
const _Unparser := preload("res://addons/oasis_dialogue/model/unparser_visitor.gd")
const _VisitorIterator := preload("res://addons/oasis_dialogue/model/visitor_iterator.gd")
const _GraphController := preload("res://addons/oasis_dialogue/canvas/graph_controller.gd")

var model: _Model = null
var lexer: _Lexer =  null
var parser: _Parser = null
var unparser: _Unparser = null
var visitors: _VisitorIterator = null
var graph_controller: _GraphController = null
## [code]func() -> _Branch[/code]
var branch_factory := Callable()
## [code]func() -> InputDialogFactory[/code]
var input_dialog_factory := Callable()
## [code]func() -> ConfirmDialogFactory[/code]
var confirm_dialog_factory := Callable()
## [code]func(id: int) -> VisitorIterator[/code]
var unbranchers_factory := Callable()
## [code]func() -> OasisDialog[/code]
var save_dialog_factory := Callable()
## [code]func() -> OasisDialog[/code]
var load_dialog_factory := Callable()

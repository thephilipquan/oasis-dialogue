extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _BranchEdit := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")

var _update_graph_branch := Callable()

var _id := -1

var _text := ""
var _line := 0
var _in_curly := false
var _seen_prompt := false
var _seen_response := false
var _add_header := false
var _header := ""


func _init(update_graph_branch: Callable) -> void:
	_update_graph_branch = update_graph_branch


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_annotation(annotation: _AST.Annotation) -> void:
	_move_line(annotation.line)
	_append_line("@%s" % annotation.name)


func visit_prompt(_prompt: _AST.Prompt) -> void:
	if not _seen_prompt:
		_seen_prompt = true
		_add_header = true
		_header = "@prompt"


func visit_response(_response: _AST.Response) -> void:
	if not _seen_response:
		_seen_response = true
		_add_header = true
		_header = "@response"


func visit_condition(condition: _AST.Condition) -> void:
	if _add_header:
		_add_header = false
		_move_line(condition.line - 1)
		_append_line(_header)
	_move_line(condition.line)
	var s := ""
	if not _in_curly:
		_in_curly = true
		s += "{"
	s += " %s" % condition.name
	_append_line(s)


func visit_action(action: _AST.Action) -> void:
	_move_line(action.line)
	var s := ""
	if not _in_curly:
		_in_curly = true
		s += " {"
	s += " %s" % action.name
	_append_line(s)


func visit_stringliteral(text: _AST.StringLiteral) -> void:
	if _add_header:
		_add_header = false
		_move_line(text.line - 1)
		_append_line(_header)
	_move_line(text.line)
	var s := ""
	if _in_curly:
		_in_curly = false
		s += " } "
	s += text.value
	_append_line(s)


func visit_numberliteral(value: _AST.NumberLiteral) -> void:
	_move_line(value.line)
	_append_line(" %d" % value.value)


func cancel() -> void:
	_id = -1
	_text = ""
	_line = 0
	_in_curly = false
	_seen_prompt = false
	_seen_response = false
	_add_header = false
	_header = ""


func finish() -> void:
	if _in_curly:
		_append_line(" }")
	_update_graph_branch.call(_id, _text)
	cancel()


func _move_line(to: int) -> void:
	if to == -1:
		return

	if to != _line and _in_curly:
		_append_line(" }")
		_in_curly = false

	for i in range(_line, to):
		_text += "\n"
	_line = to


func _append_line(text: String) -> void:
	_text += text

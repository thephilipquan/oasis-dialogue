extends Node

@export
var _label: Label = null
@export
var _character: OasisCharacter = null
@export
var _responses_parent: Node = null

var _response_index := 0
var _response_size := 0
var _started := false
var _finished := false
var _responding := false
var _traverser: OasisTraverser = null

func _ready() -> void:
	# You would set your translations via Project Settings > Localization > Translations > Add...
	TranslationServer.add_translation(preload("res://example/dialogue.en.translation"))


func _unhandled_key_input(event: InputEvent) -> void:
	var cast := event as InputEventKey
	if not cast:
		return

	if not cast.is_released():
		return

	if cast.keycode == KEY_W or cast.keycode == KEY_UP:
		up()
	elif cast.keycode == KEY_S or cast.keycode == KEY_DOWN:
		down()
	elif cast.keycode == KEY_SPACE:
		select()


func up() -> void:
	if not _responding:
		return
	_response_index = maxi(_response_index - 1, 0)
	update_responses_state()


func down() -> void:
	if not _responding:
		return
	_response_index = mini(_response_index + 1, _response_size - 1)
	update_responses_state()


func select() -> void:
	if _finished:
		return

	if not _started:
		_started = true

		# Starting a dialogue or conversation.
		_traverser = _character.start()

		# Connect to traverser signals via collision, interaction, or any means.
		# See OasisTraverser for details on when signals are emitted.
		_traverser.finished.connect(on_finished)
		_traverser.prompt.connect(prompt)
		_traverser.responses.connect(show_responses)

		# You should check if a traverser was returned. start() will return null
		# if there is an error. See OasisManager and OasisCharacter for details.
		assert(_traverser)

	_traverser.next(_response_index)


func on_finished() -> void:
	remove_responses()
	_finished = true
	_label.text = "finished"
	get_tree().create_timer(2).timeout.connect(
		func() -> void:
			_started = false
			_finished = false
			_label.text = "press space to start"
	)


func prompt(item: String) -> void:
	if _responding:
		remove_responses()
	_label.text = item


func show_responses(items: Array[String]) -> void:
	_responding = true
	_response_size = items.size()
	for i in items.size():
		var label := Label.new()
		label.text = items[i]
		_responses_parent.add_child(label)
	update_responses_state()


func update_responses_state() -> void:
	var labels := _responses_parent.get_children()
	for i in labels.size():
		var label: Label = labels[i]
		if i == _response_index:
			label.add_theme_color_override("font_color", Color.WHITE)
		else:
			label.add_theme_color_override("font_color", Color.DIM_GRAY)


func remove_responses() -> void:
	for child in _responses_parent.get_children():
		child.queue_free()
		_responses_parent.remove_child(child)
	_response_size = 0
	_responding = false
	_response_index = 0

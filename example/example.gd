## An example script that showcases how to interact with OasisDialogue.
##
## Most of the script handles input and showing prompts and responses.
## The interaction is found within [method select].
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

		# Start a dialogue or conversation.
		_traverser = _character.start()

		# You should check if a traverser was returned. start() will return null
		# if there is an error. See [method OasisCharacter.start] for details.
		assert(_traverser)

		# Connect to traverser signals via collision, interaction, or any means.
		_traverser.finished.connect(on_finished)
		_traverser.prompt.connect(prompt)
		_traverser.responses.connect(show_responses)

	# Call next for both getting the next prompt, as well as responding.
	# The response index is ignored if the traverser is not expecting a
	# response - which is only after [signal responses] is emitted.
	_traverser.next(_response_index)


# [signal OasisTraverser.finished] emits after the last prompt or response is
# 'interacted' with.
func on_finished() -> void:
	clear_responses()
	_finished = true
	_label.text = "finished"
	get_tree().create_timer(2).timeout.connect(
		func() -> void:
			_started = false
			_finished = false
			_label.text = "press space to start"
	)


# [signal OasisTraverser.prompt] emits 1 prompt at a time.
func prompt(item: String) -> void:
	if _responding:
		clear_responses()
	_label.text = item


# [signal OasisTraverser.responses] emits all responses at once.
func show_responses(items: Array[String]) -> void:
	if _responding:
		clear_responses()
	_responding = true
	_response_size = items.size()
	for i in items.size():
		var label := Label.new()
		label.text = items[i]
		_responses_parent.add_child(label)
	update_responses_state()


## Color the focused label white and the rest gray.
func update_responses_state() -> void:
	var labels := _responses_parent.get_children()
	for i in labels.size():
		var label: Label = labels[i]
		if i == _response_index:
			label.add_theme_color_override("font_color", Color.WHITE)
		else:
			label.add_theme_color_override("font_color", Color.DIM_GRAY)


## Remove all labels.
func clear_responses() -> void:
	for child in _responses_parent.get_children():
		child.queue_free()
		_responses_parent.remove_child(child)
	_response_size = 0
	_responding = false
	_response_index = 0

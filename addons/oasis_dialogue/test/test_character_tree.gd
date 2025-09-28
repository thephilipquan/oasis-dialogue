extends GutTest

const CharacterTree := preload("res://addons/oasis_dialogue/canvas/character_tree.gd")

var sut: CharacterTree = null


func before_each() -> void:
	sut = add_child_autofree(CharacterTree.new())


func test_root_is_not_null() -> void:
	assert_ne(sut.get_root(), null)


func test_add_item() -> void:
	sut.add_item("foo")

	var got := sut.get_root().get_children()[0]
	assert_eq(got.get_text(0), "foo")


func test_remove_selected_item() -> void:
	sut.add_item("foo")
	sut.get_root().get_children()[0].select(0)

	sut.remove_selected_item()

	assert_eq(sut.get_root().get_child_count(), 0)


func test_edit_seleted_item() -> void:
	sut.add_item("foo")
	sut.get_root().get_children()[0].select(0)

	sut.edit_selected_item("bar")

	var item := sut.get_root().get_children()[0]
	assert_eq(item.get_text(0), "bar")



func test_set_items() -> void:
	var items: Array[String] = [
		"foo",
		"bar",
		"buz",
	]
	sut.set_items(items)

	var got := sut.get_root().get_children().map(
		func(i: TreeItem): return i.get_text(0)
	)
	assert_eq_deep(got, items)


func test_item_selected_emits_character_selected() -> void:
	watch_signals(sut)
	sut.add_item("foo")
	sut.get_root().get_children()[0].select(0)

	assert_signal_emitted_with_parameters(sut.character_selected, ["foo"])


func test_item_activated_emits_character_activated() -> void:
	watch_signals(sut)
	sut.add_item("foo")
	sut.get_root().get_children()[0].select(0)

	sut._on_item_activated()

	assert_signal_emitted(sut.character_activated)


func test_load_project() -> void:
	var data := {
		"characters": [
			"a",
			"b",
		],
	}
	sut.load_project(data)

	var got := sut.get_root().get_children().map(func(i: TreeItem): return i.get_text(0))
	assert_eq(got, [ "a", "b" ])


func test_load_project_overwrites() -> void:
	var data := {
		"characters": [
			"a",
			"b",
		],
	}
	sut.load_project(data)

	data = {
		"characters": [
			"c",
			"d",
		],
	}
	sut.load_project(data)

	var got := sut.get_root().get_children().map(func(i: TreeItem): return i.get_text(0))
	assert_eq(got, [ "c", "d" ])

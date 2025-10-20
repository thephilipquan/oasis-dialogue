extends GutTest

const Save := preload("res://addons/oasis_dialogue/save.gd")
const CharacterTree := preload("res://addons/oasis_dialogue/canvas/character_tree.gd")

var sut: CharacterTree = null


func before_each() -> void:
	sut = add_child_autofree(CharacterTree.new())


func test_root_is_not_null() -> void:
	assert_ne(sut.get_root(), null)


func test_add_item() -> void:
	sut.add_item("foo")

	assert_not_null(sut.find_item("foo"))


func test_get_selected_returns_selected_text() -> void:
	sut.add_item("a")
	sut.select_item(sut.find_item("a"))
	assert_eq(sut.get_selected_item(), "a")


func test_get_selected_returns_blank_if_nothing_selected() -> void:
	sut.add_item("a")
	assert_eq(sut.get_selected_item(), "")


func test_remove_selected_item() -> void:
	sut.add_item("a")
	sut.select_item(sut.find_item("a"))
	sut.remove_selected_item()
	assert_null(sut.find_item("a"))


func test_edit_seleted_item() -> void:
	sut.add_item("a")
	sut.select_item(sut.find_item("a"))
	sut.edit_selected_item("b")

	assert_null(sut.find_item("a"))
	assert_not_null(sut.find_item("b"))


func test_set_items() -> void:
	var items: Array[String] = [
		"a",
		"b",
		"c",
	]
	sut.set_items(items)

	for item in ["a", "b", "c"]:
		assert_not_null(sut.find_item(item))


func test_set_items_overwrites_previous_items() -> void:
	sut.set_items(["a"])
	sut.set_items(["b"])

	assert_null(sut.find_item("a"))


func test_select_item_emits_character_selected() -> void:
	sut.add_item("a")
	var item := sut.find_item("a")
	watch_signals(sut)
	sut.select_item(item)

	assert_signal_emitted_with_parameters(sut.character_selected, ["a"])


func test_item_activated_emits_character_activated() -> void:
	sut.add_item("a")
	var item := sut.find_item("a")
	sut.select_item(item)

	watch_signals(sut)
	# Mock user double clicking.
	sut._on_item_activated()

	assert_signal_emitted(sut.character_activated)


func test_load_settings_sets_items() -> void:
	var file := ConfigFile.new()
	file.set_value(
			Save.Project.CHARACTERS,
			Save.DUMMY,
			["a", "b"],
	)
	sut.load_settings(file)

	var got := sut.get_root().get_children().map(func(i: TreeItem): return i.get_text(0))
	assert_eq(got, [ "a", "b" ])


func test_load_settings_with_active_selects_item() -> void:
	var file := ConfigFile.new()
	file.set_value(
			Save.Project.CHARACTERS,
			Save.DUMMY,
			["a"],
	)
	file.set_value(
			Save.Project.SESSION,
			Save.Project.Session.ACTIVE,
			"a",
	)
	watch_signals(sut)

	sut.load_settings(file)

	assert_signal_emitted_with_parameters(sut.character_selected, ["a"])

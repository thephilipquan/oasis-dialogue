extends GutTest

const Global := preload("res://addons/oasis_dialogue/global.gd")
const ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")

const BASEDIR := "res://"
const TESTDIR := "res://test_dir"

var sut: ProjectManager = null


func before_all() -> void:
	assert(BASEDIR == TESTDIR.get_base_dir())
	var dir := DirAccess.open(BASEDIR)
	dir.make_dir(TESTDIR.get_basename())
	# Check if any files exist before running.
	after_each()


func after_all() -> void:
	var dir := DirAccess.open(BASEDIR)
	dir.remove(TESTDIR.get_basename())


func before_each() -> void:
	sut = ProjectManager.new()


func after_each() -> void:
	var dir := DirAccess.open(TESTDIR)

	var to_remove: Array[String] = []
	var files := dir.get_files()
	for file in files:
		if file.get_extension() == ProjectManager.EXTENSION:
			to_remove.push_back(file)
		else:
			fail_test("created badly formed file: %s" % file)
			to_remove.push_back(file)
	to_remove.map(func(f: String): dir.remove(f))
	to_remove.clear()

	dir = DirAccess.open(BASEDIR)
	files = dir.get_files()
	for file in files:
		if file.get_extension() == ProjectManager.EXTENSION:
			fail_test("Created %s in %s when it should be created in %s." % [
				file,
				BASEDIR,
				TESTDIR,
			])
			to_remove.push_back(file)
	to_remove.map(func(f: String): dir.remove(f))
	to_remove.clear()


func test_get_settings_path() -> void:
	sut._directory = "hey"

	assert_eq(sut.get_settings_path(), "hey/%s" % ProjectManager.SETTINGS)


func test_get_subfile_path() -> void:
	sut._directory = "hey"

	assert_eq(
		sut.get_subfile_path("tim"),
		"hey/tim.%s" % ProjectManager.EXTENSION
	)


func test_new_project_set_directory_member() -> void:
	sut.new_project(TESTDIR)

	var settings := sut.get_settings_path()
	assert_eq(sut._directory, TESTDIR)


func test_new_project_creates_settings_file() -> void:
	sut.new_project(TESTDIR)

	assert_true(FileAccess.file_exists(sut.get_settings_path()))


func test_can_rename_active_to() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("fred")
	sut.load_subfile("fred")

	assert_true(sut.can_rename_active_to("Fred"))


func test_can_rename_active_to_with_alternate_casing() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("FRED")
	sut.load_subfile("FRED")

	assert_true(sut.can_rename_active_to("fred"))
	assert_true(sut.can_rename_active_to("Fred"))
	assert_true(sut.can_rename_active_to("fRED"))


func test_can_rename_active_to_other_existing() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("tim")
	sut.add_subfile("fred")
	sut.load_subfile("fred")

	assert_false(sut.can_rename_active_to("tim"))
	assert_false(sut.can_rename_active_to("Tim"))
	assert_false(sut.can_rename_active_to("TIM"))
	assert_false(sut.can_rename_active_to("tIM"))


func test_add_subfile() -> void:
	sut.new_project(TESTDIR)

	sut.add_subfile("tim")

	var tim := sut.get_subfile_path("tim")
	assert_true(FileAccess.file_exists(tim))


func test_add_subfile_already_exists_do_nothing() -> void:
	sut.new_project(TESTDIR)

	sut.add_subfile("tim")
	var file := FileAccess.open(sut.get_subfile_path("tim"), FileAccess.WRITE)
	file.store_string("hey there")
	file.close()
	sut.add_subfile("tim")

	file = FileAccess.open(sut.get_subfile_path("tim"), FileAccess.READ)
	assert_eq(file.get_as_text(), "hey there")
	file.close()


func test_add_subfile_adds_display_name_to_conversion_map() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("TIM")
	sut.add_subfile("fred")

	assert_eq(sut._display_to_filename.get("TIM", ""), "tim")
	assert_eq(sut._display_to_filename.get("fred", ""), "fred")


func test_load_subfile_emits_file_loaded() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("fred")

	var file := FileAccess.open(
		sut.get_subfile_path("fred"),
		FileAccess.WRITE,
	)
	var contents := {
		"name": "fred",
		"foo": "bar"
	}
	file.store_string(JSON.stringify(contents))
	file.close()

	watch_signals(sut)
	sut.load_subfile("fred")

	var parameters = get_signal_parameters(sut.file_loaded)
	if not parameters:
		fail_test("")
		return

	assert_eq(sut._active, "fred")
	assert_signal_emitted(sut.file_loaded)
	assert_eq_deep(parameters[0], contents)


func test_load_subfile_not_exists_do_nothing() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("fred")

	watch_signals(sut)
	sut.load_subfile("tim")

	assert_signal_not_emitted(sut.file_loaded)


func test_load_subfile_already_loaded() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("fred")
	sut.load_subfile("fred")
	watch_signals(sut)

	sut.load_subfile("fred")

	assert_signal_not_emitted(sut.file_loaded)


func test_load_subfile_emits_saving_file_if_previously_loaded_another() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("fred")
	sut.load_subfile("fred")
	sut.add_subfile("tim")
	watch_signals(sut)

	sut.load_subfile("tim")

	assert_signal_emitted(sut.saving_file)


func test_save_active_subfile_emits_saving_file() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("fred")
	sut.load_subfile("fred")
	watch_signals(sut)

	sut.save_active_subfile()

	assert_signal_emitted(sut.saving_file)


func test_save_active_subfile_adds_display_name_to_saving_file_data() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("fred")
	sut.load_subfile("fred")
	watch_signals(sut)

	sut.save_active_subfile()

	var got = get_signal_parameters(sut.saving_file)
	if not got:
		fail_test("")
		return

	var data: Dictionary = got[0]
	assert_eq(data.get(Global.FILE_DISPLAY_NAME, ""), "fred")


func test_rename_active_subfile_updates_active() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("fred")
	sut.load_subfile("fred")

	sut.rename_active_subfile("tim")

	assert_eq(sut._active, "tim")


func test_rename_active_subfile_updates_conversion_dictionary() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("fred")
	sut.load_subfile("fred")

	sut.rename_active_subfile("Tim")

	assert_has(sut._display_to_filename, "Tim")
	assert_does_not_have(sut._display_to_filename, "fred")


func test_rename_active_subfile_replaces_file() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("fred")
	sut.load_subfile("fred")

	sut.rename_active_subfile("tim")

	var fred := sut.get_subfile_path("fred")
	var tim := sut.get_subfile_path("tim")

	assert_false(FileAccess.file_exists(fred))
	assert_true(FileAccess.file_exists(tim))


func test_rename_active_subfile_calls_save_active_subfile() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("fred")
	sut.load_subfile("fred")
	watch_signals(sut)

	sut.rename_active_subfile("tim")

	assert_signal_emitted(sut.saving_file)


func test_rename_active_subfile_to_same_display_name_does_nothing() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("FRED")
	sut.load_subfile("FRED")
	watch_signals(sut)

	sut.rename_active_subfile("FRED")

	assert_signal_not_emitted(sut.saving_file)


func test_rename_active_subfile_already_exists_do_nothing() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("fred")
	sut.add_subfile("tim")
	sut.load_subfile("fred")
	watch_signals(sut)

	sut.rename_active_subfile("tim")

	assert_eq(sut._active, "fred")
	assert_signal_not_emitted(sut.saving_file)


func test_rename_active_subfile_old_active_display_name_is_removed_from_conversion_dictionary() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("fred")
	var file := FileAccess.open(sut.get_subfile_path("fred"), FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"display_name": "Fred",
	}))
	file.close()
	sut.load_subfile("fred")

	sut.rename_active_subfile("Tim")

	assert_false("Fred" in sut._display_to_filename)
	assert_true("Tim" in sut._display_to_filename)


func test_load_project_emits_project_loaded() -> void:
	var settings := FileAccess.open(
		TESTDIR.path_join(ProjectManager.SETTINGS),
		 FileAccess.WRITE
	)
	var contents := { "active": "fred" }
	settings.store_string(JSON.stringify(contents))
	settings.close()
	stub(sut.load_subfile).to_do_nothing()
	watch_signals(sut)

	sut.load_project(TESTDIR)

	var parameters = get_signal_parameters(sut.project_loaded)
	if not parameters:
		fail_test("")
		return
	assert_signal_emitted(sut.project_loaded)
	assert_eq(parameters[0], contents)


func test_load_project_fails_if_settings_not_exists() -> void:
	watch_signals(sut)
	sut.load_project(TESTDIR)

	assert_signal_not_emitted(sut.project_loaded)
	assert_false(FileAccess.file_exists(sut.get_settings_path()))


func test_load_project_sets_conversion_dictionary() -> void:
	var dir := DirAccess.open(BASEDIR)
	dir.make_dir(TESTDIR.get_basename())

	FileAccess.open(
			TESTDIR.path_join(ProjectManager.SETTINGS),
			FileAccess.WRITE
	)
	FileAccess.open(
			TESTDIR.path_join("joe.%s" % ProjectManager.EXTENSION),
			FileAccess.WRITE
	)
	FileAccess.open(
			TESTDIR.path_join("sam.%s" % ProjectManager.EXTENSION),
			FileAccess.WRITE
	).store_string(JSON.stringify({
			"display_name": "SAM",
	}))
	stub(sut.load_subfile).to_do_nothing()

	sut.load_project(TESTDIR)

	assert_eq_deep(sut._display_to_filename, { "joe": "joe", "SAM": "sam" })


func test_load_project_emits_display_names() -> void:
	var dir := DirAccess.open(BASEDIR)
	dir.make_dir(TESTDIR.get_basename())

	FileAccess.open(
		TESTDIR.path_join(ProjectManager.SETTINGS),
		FileAccess.WRITE
	)
	FileAccess.open(
		TESTDIR.path_join("joe.%s" % ProjectManager.EXTENSION),
		FileAccess.WRITE
	)
	FileAccess.open(
		TESTDIR.path_join("sam.%s" % ProjectManager.EXTENSION),
		FileAccess.WRITE
	).store_string(JSON.stringify({
			"display_name": "SAM",
	}))
	stub(sut.load_subfile).to_do_nothing()
	watch_signals(sut)

	sut.load_project(TESTDIR)

	var got = get_signal_parameters(sut.project_loaded)
	if not got:
		fail_test("")
		return

	var expected := {
		Global.LOAD_PROJECT_CHARACTERS: ["joe", "SAM"],
	}
	assert_eq_deep(got[0], expected)


func test_load_project_call_load_file_if_active_is_non_empty() -> void:
	var settings := FileAccess.open(
		TESTDIR.path_join(ProjectManager.SETTINGS),
		 FileAccess.WRITE
	)
	var contents := { "active": "fred" }
	settings.store_string(JSON.stringify(contents))
	settings.close()

	var file := FileAccess.open(
		TESTDIR.path_join("fred.%s" % ProjectManager.EXTENSION),
		 FileAccess.WRITE
	)
	watch_signals(sut)

	sut.load_project(TESTDIR)

	assert_signal_emitted(sut.file_loaded)


func test_load_project_not_calls_load_subfile_if_active_empty() -> void:
	var settings := FileAccess.open(
		TESTDIR.path_join(ProjectManager.SETTINGS),
		FileAccess.WRITE
	)
	var contents := {
		"active": "",
	}
	settings.store_string(JSON.stringify(contents))
	settings.close()
	var fred := FileAccess.open(
		TESTDIR.path_join("fred.%s" % ProjectManager.EXTENSION),
		FileAccess.WRITE
	)
	fred.close()
	watch_signals(sut)

	sut.load_project(TESTDIR)

	assert_signal_not_emitted(sut.file_loaded)


func test_load_project_clears_fields() -> void:
	sut._directory = "baz"
	sut._active = "foo"
	sut._display_to_filename["foo"] = "bar"

	FileAccess.open(
		TESTDIR.path_join(ProjectManager.SETTINGS),
		FileAccess.WRITE,
	)
	sut.load_project(TESTDIR)

	assert_ne(sut._directory, "baz")
	assert_ne(sut._active, "foo")
	assert_false("bar" in sut._display_to_filename)


func test_save_project() -> void:
	sut.new_project(TESTDIR)

	watch_signals(sut)
	sut.save_project()

	assert_signal_emitted(sut.saving_project)


func test_remove_active_subfile() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("tim")
	sut.load_subfile("tim")

	sut.remove_active_subfile()

	assert_eq(sut._active, "")
	assert_false(FileAccess.file_exists(sut.get_subfile_path("tim")))


func test_save_project_with_empty_directory() -> void:
	watch_signals(sut)
	sut.save_project()

	assert_signal_not_emitted(sut.saving_project)
	assert_false(FileAccess.file_exists(sut.get_settings_path()))


func test_add_subfile_with_empty_directory() -> void:
	sut.add_subfile("tim")

	assert_false(FileAccess.file_exists(
		TESTDIR.path_join("tim.%s" % ProjectManager.EXTENSION)
	))
	assert_false(FileAccess.file_exists(
		BASEDIR.path_join("tim.%s" % ProjectManager.EXTENSION)
	))


func test_load_subfile_with_empty_directory() -> void:
	watch_signals(sut)
	sut.load_subfile("tim")

	assert_signal_not_emitted(sut.file_loaded)


func test_load_subfile_emits_name_in_data() -> void:
	sut.new_project(TESTDIR)
	sut.add_subfile("fred")

	var file := FileAccess.open(
		TESTDIR.path_join("fred.%s" % ProjectManager.EXTENSION),
		FileAccess.WRITE
	)
	watch_signals(sut)

	sut.load_subfile("fred")

	var got = get_signal_parameters(sut.file_loaded)
	if not got:
		fail_test("")
		return
	assert_eq(got[0], { "name": "fred" })


func test_remove_active_subfile_with_empty_directory() -> void:
	sut._active = "foo"

	sut.remove_active_subfile()

	assert_eq(sut._active, "foo")


func test_rename_active_subfile_with_empty_directory() -> void:
	sut._active = "foo"

	sut.rename_active_subfile("tim")

	assert_eq(sut._active, "foo")

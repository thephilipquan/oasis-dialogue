extends GutTest

const Global := preload("res://addons/oasis_dialogue/global.gd")
const Save := preload("res://addons/oasis_dialogue/save.gd")
const OasisFile := preload("res://addons/oasis_dialogue/oasis_file.gd")
const ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")

const BASEDIR := "res://"
const TESTDIR := "res://test_dir"

var sut: ProjectManager = null


func disconnect_all(s: Signal) -> void:
	for c in s.get_connections():
		s.disconnect(c["callable"])


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
	sut = add_child_autofree(ProjectManager.new())


func after_each() -> void:
	var dir := DirAccess.open(TESTDIR)

	for file in dir.get_files():
		dir.remove(file)
	for directory in dir.get_directories():
		for file in dir.get_files_at(TESTDIR.path_join(directory)):
			dir.remove(TESTDIR.path_join(directory).path_join(file))
		dir.remove(directory)


func test_can_rename_active_to_different_name_returns_true() -> void:
	sut.open_project(TESTDIR)
	sut.add_character("fred")
	sut.load_character("fred")

	assert_true(sut.can_rename_active_to("Fred"))


func test_can_rename_active_to_with_different_casing_returns_true() -> void:
	sut.open_project(TESTDIR)
	sut.add_character("FRED")
	sut.load_character("FRED")

	assert_true(sut.can_rename_active_to("fred"))
	assert_true(sut.can_rename_active_to("Fred"))


func test_can_rename_active_to_existing_file_returns_false() -> void:
	sut.open_project(TESTDIR)
	sut.add_character("tim")
	sut.add_character("fred")
	sut.load_character("fred")

	assert_false(sut.can_rename_active_to("tim"))
	assert_false(sut.can_rename_active_to("TIM"))


func test_get_active_character_returns_loaded_character() -> void:
	sut.open_project(TESTDIR)
	sut.add_and_load_character("Fred")
	assert_eq(sut.get_active_character(), "Fred")


func test_open_project_restores_settings() -> void:
	sut.open_project(TESTDIR)
	sut.saving_settings.connect(
			func(data: ConfigFile):
				data.set_value("a", "b", 1)
	)
	sut.save_project()

	sut = add_child_autofree(ProjectManager.new())
	sut.settings_loaded.connect(
			func(data: ConfigFile):
				assert_eq(data.get_value("a", "b", -1), 1)
	)
	sut.open_project(TESTDIR)


func test_open_project_restores_conditions() -> void:
	sut.open_project(TESTDIR)
	sut.saving_conditions.connect(
			func(data: OasisFile):
				data.set_value(Save.DUMMY, "a\nb")
	)
	sut.save_project()

	sut = add_child_autofree(ProjectManager.new())
	sut.conditions_loaded.connect(
			func(data: OasisFile):
				assert_eq_deep(data.get_value(Save.DUMMY), "a\nb")
	)
	sut.open_project(TESTDIR)


func test_open_project_restores_actions() -> void:
	sut.open_project(TESTDIR)
	sut.saving_actions.connect(
			func(data: OasisFile):
				data.set_value(Save.DUMMY, "a\nb")
	)
	sut.save_project()

	sut = add_child_autofree(ProjectManager.new())
	sut.actions_loaded.connect(
			func(data: OasisFile):
				assert_eq_deep(data.get_value(Save.DUMMY), "a\nb")
	)
	sut.open_project(TESTDIR)


func test_unexpected_quit_restores_unsaved_changes() -> void:
	sut.open_project(TESTDIR)
	sut.add_and_load_character("fred")
	sut.mark_active_character_dirty()
	sut.saving_character.connect(
			func(data: OasisFile):
				data.set_value("a", "b"),
			CONNECT_ONE_SHOT,
	)
	sut.add_and_load_character("tom")

	sut = add_child_autofree(ProjectManager.new())
	sut.open_project(TESTDIR)
	sut.character_loaded.connect(
			func(data: OasisFile):
				assert_eq(data.get_value("a", ""), "b"),
	)
	sut.load_character("fred")


func test_quit_removes_unsaved_changes() -> void:
	sut.open_project(TESTDIR)
	sut.add_and_load_character("fred")
	sut.mark_active_character_dirty()
	sut.saving_character.connect(
			func(data: OasisFile):
				data.set_value("a", "b"),
			CONNECT_ONE_SHOT,
	)
	sut.add_and_load_character("tom")
	sut.quit()

	sut = add_child_autofree(ProjectManager.new())
	sut.open_project(TESTDIR)
	sut.character_loaded.connect(
			func(data: OasisFile):
				assert_false(data.has_key("a")),
	)
	sut.load_character("fred")


func test_load_character_emits_character_loaded() -> void:
	sut.open_project(TESTDIR)
	sut.add_character("fred")

	watch_signals(sut)
	sut.load_character("fred")
	assert_signal_emitted(sut.character_loaded)


func test_save_character_emits_saving_character() -> void:
	sut.open_project(TESTDIR)
	sut.add_and_load_character("fred")

	watch_signals(sut)
	sut.save_active_character()
	assert_signal_emitted(sut.saving_character)


func test_save_character_config_emits_saving_character_config() -> void:
	sut.open_project(TESTDIR)
	sut.add_and_load_character("fred")

	watch_signals(sut)
	sut.save_active_character_config()
	assert_signal_emitted(sut.saving_character_config)


func test_load_character_restores_saved_character_data() -> void:
	sut.open_project(TESTDIR)
	sut.add_and_load_character("fred")
	sut.mark_active_character_dirty()
	sut.saving_character.connect(
			func(data: OasisFile):
				data.set_value("a", "hello world")
	)
	sut.save_active_character()
	sut.quit()

	sut = add_child_autofree(ProjectManager.new())
	sut.open_project(TESTDIR)
	sut.character_loaded.connect(
			func(data: OasisFile):
				assert_eq(data.get_value("a", ""), "hello world")
	)
	sut.load_character("fred")


func test_load_character_restores_saved_character_config() -> void:
	sut.open_project(TESTDIR)
	sut.add_and_load_character("fred")
	sut.saving_character_config.connect(
			func(data: ConfigFile):
				data.set_value("a", "b", "hello world")
	)
	sut.save_active_character_config()
	sut.quit()

	sut = add_child_autofree(ProjectManager.new())
	sut.open_project(TESTDIR)
	sut.character_config_loaded.connect(
			func(data: ConfigFile):
				assert_eq(data.get_value("a", "b", ""), "hello world")
	)
	sut.load_character("fred")


func test_switching_characters_restores_unsaved_changes() -> void:
	sut.open_project(TESTDIR)
	sut.add_character("fred")
	sut.add_character("tom")
	sut.load_character("fred")

	sut.mark_active_character_dirty()
	sut.saving_character.connect(
			func(data: OasisFile):
				data.set_value("a", "b"),
			CONNECT_ONE_SHOT,
	)
	sut.load_character("tom")
	sut.character_loaded.connect(
			func(data: OasisFile):
				assert_eq(data.get_value("a", ""), "b")
	)
	sut.load_character("fred")


func test_switching_characters_restores_config() -> void:
	sut.open_project(TESTDIR)
	sut.add_and_load_character("fred")
	sut.mark_active_character_dirty()
	sut.saving_character_config.connect(
			func(config: ConfigFile):
				config.set_value("a", "b", "c"),
			CONNECT_ONE_SHOT,
	)
	sut.add_and_load_character("tom")
	sut.character_config_loaded.connect(
			func(config: ConfigFile):
				assert_eq(config.get_value("a", "b", ""), "c")
	)
	sut.load_character("fred")


func test_save_project_saves_unsaved_changes() -> void:
	sut.open_project(TESTDIR)
	sut.add_and_load_character("fred")
	sut.mark_active_character_dirty()
	sut.saving_character.connect(
			func(data: OasisFile):
				data.set_value("a", "b"),
			CONNECT_ONE_SHOT,
	)
	sut.add_and_load_character("tom")
	sut.mark_active_character_dirty()
	sut.saving_character.connect(
			func(data: OasisFile):
				data.set_value("c", "d"),
			CONNECT_ONE_SHOT,
	)
	sut.save_project()
	sut.quit()

	sut = add_child_autofree(ProjectManager.new())
	sut.open_project(TESTDIR)
	sut.character_loaded.connect(
			func(data: OasisFile):
				assert_eq(data.get_value("a", ""), "b"),
			CONNECT_ONE_SHOT,
	)
	sut.load_character("fred")
	sut.character_loaded.connect(
			func(data: OasisFile):
				assert_eq(data.get_value("c", ""), "d"),
			CONNECT_ONE_SHOT,
	)
	sut.load_character("tom")


func test_remove_active_character() -> void:
	sut.open_project(TESTDIR)
	sut.add_and_load_character("fred")
	sut.remove_active_character()

	assert_false(sut.character_exists("fred"))


func test_remove_active_character_removes_unsaved_changes() -> void:
	sut.open_project(TESTDIR)
	sut.add_and_load_character("fred")
	sut.mark_active_character_dirty()
	sut.saving_character.connect(
			func(data: OasisFile):
				data.set_value("a", "b"),
			CONNECT_ONE_SHOT,
	)
	sut.add_and_load_character("tom")
	disconnect_all(sut.saving_character)
	sut.load_character("fred")
	sut.remove_active_character()

	sut.character_loaded.connect(
			func(data: OasisFile):
				assert_false(data.has_key("a")),
	)
	sut.add_and_load_character("fred")


func test_remove_active_character_removes_character_config() -> void:
	sut.open_project(TESTDIR)
	sut.add_and_load_character("fred")
	sut.saving_character_config.connect(
			func(data: ConfigFile):
				data.set_value("a", "b", "c"),
			CONNECT_ONE_SHOT,
	)
	sut.add_and_load_character("tom")
	disconnect_all(sut.saving_character_config)
	sut.load_character("fred")
	sut.remove_active_character()

	sut.character_config_loaded.connect(
			func(data: ConfigFile):
				assert_false(data.has_section_key("a", "b"))
	)
	sut.add_and_load_character("fred")


func test_rename_active_character_removes_previous_name_data() -> void:
	sut.open_project(TESTDIR)
	sut.add_and_load_character("fred")
	sut.mark_active_character_dirty()
	sut.saving_character.connect(
			func(file: OasisFile):
				file.set_value("a", "b"),
			CONNECT_ONE_SHOT,
	)
	sut.saving_character_config.connect(
			func(file: ConfigFile):
				file.set_value("c", "d", "e"),
			CONNECT_ONE_SHOT,
	)
	sut.add_and_load_character("tom")
	sut.load_character("fred")

	sut.rename_active_character("bob")
	sut.character_loaded.connect(
			func(file: OasisFile):
				assert_false(file.has_key("a"), "fred temp file was never removed"),
	)
	sut.character_config_loaded.connect(
			func(file: ConfigFile):
				assert_false(file.has_section_key("c", "d"), "fred config file was never removed"),
	)
	sut.add_and_load_character("fred")

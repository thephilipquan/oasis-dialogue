@tool
extends FileDialog

signal selected(path: String)

var _default_filename := ""
var _extension := ""


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	access = FileDialog.ACCESS_FILESYSTEM

	hidden_files_toggle_enabled = false
	folder_creation_enabled = true
	file_filter_toggle_enabled = false
	file_sort_options_enabled = false
	favorites_enabled = false
	recent_list_enabled = false
	layout_toggle_enabled = true

	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	display_mode = FileDialog.DISPLAY_LIST

	if _extension:
		filters = PackedStringArray(["*.%s" % _extension])

	if file_mode == FileMode.FILE_MODE_SAVE_FILE:
		if _default_filename:
			get_line_edit().text = _default_filename
		confirmed.connect(_on_confirm)
	else:
		file_selected.connect(_emit_selected)
		dir_selected.connect(_emit_selected)
	show()


func init_default_filename(filename: String) -> void:
	_default_filename = filename


func init_extension(extension: String) -> void:
	_extension = extension


func init_file_mode(filemode: FileMode) -> void:
	file_mode = filemode


func _on_confirm() -> void:
	var path := current_dir.path_join(get_line_edit().text)
	selected.emit(path)


func _emit_selected(path := "") -> void:
	selected.emit(path)

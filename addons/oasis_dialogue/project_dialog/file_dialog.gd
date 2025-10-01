@tool
extends FileDialog

signal selected(path: String)

const EXTENSION := "oasis"


func _ready() -> void:
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

	filters = PackedStringArray(["*.%s" % EXTENSION])
	show()


func init(mode: FileMode) -> void:
	if mode == FileMode.FILE_MODE_SAVE_FILE:
		get_line_edit().text = "game_name.%s" % EXTENSION
		confirmed.connect(_on_confirm)
	else:
		file_selected.connect(_emit_selected)
		dir_selected.connect(_emit_selected)
	file_mode = mode


func _on_confirm() -> void:
	var path := current_dir.path_join(get_line_edit().text)
	selected.emit(path)


func _emit_selected(path := "") -> void:
	selected.emit(path)

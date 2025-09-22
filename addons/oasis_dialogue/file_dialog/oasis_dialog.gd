extends FileDialog

signal selected(path: String)

const EXTENSION := "oasis"


func _ready() -> void:
	access = FileDialog.ACCESS_FILESYSTEM

	hidden_files_toggle_enabled = false
	folder_creation_enabled = false
	file_filter_toggle_enabled = false
	file_sort_options_enabled = false
	favorites_enabled = false
	recent_list_enabled = false
	layout_toggle_enabled = true

	filters = PackedStringArray(["*.%s" % EXTENSION])
	confirmed.connect(_emit_selected)
	file_selected.connect(_emit_selected)
	show()


func init(mode: FileMode) -> void:
	if mode == FileMode.FILE_MODE_SAVE_FILE:
		get_line_edit().text = "game_name.%s" % EXTENSION
	file_mode = mode


func _emit_selected(path := "") -> void:
	if not path:
		path = current_dir.path_join(get_line_edit().text)
	selected.emit(path)

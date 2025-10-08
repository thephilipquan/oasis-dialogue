extends GutTest

const Status := preload("res://addons/oasis_dialogue/status/status.gd")
const StatusScene := preload("res://addons/oasis_dialogue/status/status.tscn")
const StatusLabel := preload("res://addons/oasis_dialogue/status/status_label.gd")
const StatusLabelScene := preload("res://addons/oasis_dialogue/status/status_label.tscn")

var sut: Status = null
var labels: Array[StatusLabel] = []

func label_factory() -> StatusLabel:
	var label: StatusLabel = double(StatusLabelScene).instantiate()
	labels.push_back(label)
	return label


func before_each() -> void:
	labels.clear()
	sut = StatusScene.instantiate()
	sut.init_status_label_factory(label_factory)
	add_child_autofree(sut)


func test_info_adds_label_with_message() -> void:
	sut.info("foo")

	assert_called(labels[0], "init", ["foo", sut._duration])


func test_clear_labels_removes_all_labels() -> void:
	sut.info("foo")
	sut.info("bar")

	sut.clear_labels()
	await wait_physics_frames(1)

	for i in labels.size():
		assert_null(labels[i])


func test_err_creates_label_with_message() -> void:
	sut.err(3, "foo")

	assert_called(labels[0], "init", ["foo", 0.0])


func test_err_with_same_id_removes_old_label() -> void:
	sut.err(3, "foo")
	sut.err(3, "bar")

	await wait_physics_frames(1)

	assert_null(labels[0])


func test_err_with_different_id_appends_label() -> void:
	sut.err(3, "foo")
	sut.err(4, "bar")

	await wait_physics_frames(1)

	assert_not_null(labels[0])


func test_clear_err_calls_fade_on_label() -> void:
	sut.err(3, "foo")

	sut.clear_err(3)

	assert_called(labels[0].fade)


func test_clear_err_with_non_existing_id_does_nothing() -> void:
	sut.err(3, "foo")

	sut.clear_err(4)

	assert_not_called(labels[0].fade)
	assert_not_null(labels[0])


func test_clear_errs_removes_all_errs_and_leaves_info_labels() -> void:
	sut.err(2, "foo")
	sut.err(3, "bar")
	sut.err(4, "baz")

	sut.clear_errs()

	await wait_physics_frames(1)

	for i in labels.size():
		assert_null(labels[i])

extends Node

const SAVE_PATH := "user://save/sweet_home_save.json"

func save_game(data: Dictionary) -> void:
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("save"):
		dir.make_dir("save")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return _default_save()
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return _default_save()
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return _default_save()
	return parsed

func reset_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func _default_save() -> Dictionary:
	return {
		"total_xp": 0,
		"accepted_quest": {},
		"shown_decoration_ids": [],
		"last_play_date": "",
	}

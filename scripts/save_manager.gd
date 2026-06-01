extends Node

const SAVE_PATH := "user://save/sweet_home_save.json"

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return default_save()
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return default_save()
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return default_save()
	var defaults := default_save()
	for key in defaults:
		if not parsed.has(key):
			parsed[key] = defaults[key]
	return parsed

func save_game(data: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute("user://save")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func reset_save() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		return DirAccess.remove_absolute(SAVE_PATH) == OK
	return true

func default_save() -> Dictionary:
	return {
		"total_xp": 0,
		"accepted_quest": {},
		"shown_decoration_ids": [],
		"last_play_date": "",
	}

extends Node

const SAVE_PATH := "user://sweet_home_save.json"

const DEFAULT_STATE := {
	"version": 1,
	"members": [
		{"name": "冒險者A", "level": 1, "exp": 0, "role": "見習整理師"},
	],
	"completed_quests": [],
	"pending_quests": [],
}

func load_state() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return DEFAULT_STATE.duplicate(true)

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("SaveSystem: cannot read save file")
		return DEFAULT_STATE.duplicate(true)

	var parsed := JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return DEFAULT_STATE.duplicate(true)

func save_state(state: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveSystem: cannot write save file")
		return
	file.store_string(JSON.stringify(state, "\t"))

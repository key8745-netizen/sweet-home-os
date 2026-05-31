extends Control

signal quest_accepted(quest: Dictionary)

const QUEST_DATA_PATH := "res://data/quests.json"

var _quests: Array[Dictionary] = []

func _ready() -> void:
	_load_quests()
	_render_quests()

func _load_quests() -> void:
	var file := FileAccess.open(QUEST_DATA_PATH, FileAccess.READ)
	if file == null:
		push_warning("QuestBoard: cannot open %s" % QUEST_DATA_PATH)
		return
	var parsed := JSON.parse_string(file.get_as_text())
	if parsed is Array:
		for q in parsed:
			if q is Dictionary:
				_quests.append(q)

func _render_quests() -> void:
	var list := $QuestList
	for child in list.get_children():
		child.queue_free()

	for quest in _quests:
		if quest.get("status", "available") != "available":
			continue
		var btn := Button.new()
		btn.text = "[%s] %s" % [quest.get("difficulty", "?"), quest.get("title", "")]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_quest_button_pressed.bind(quest))
		list.add_child(btn)

func _on_quest_button_pressed(quest: Dictionary) -> void:
	quest_accepted.emit(quest)

extends Node2D

const SaveSystem = preload("res://scripts/save_system.gd")

var save_system: SaveSystem

func _ready() -> void:
	save_system = SaveSystem.new()
	add_child(save_system)

	var state := save_system.load_state()
	_apply_state(state)

	$QuestBoard.quest_accepted.connect(_on_quest_accepted)

func _apply_state(state: Dictionary) -> void:
	var members: Array = state.get("members", [])
	var member_list := $PartyStatus/MemberList
	for child in member_list.get_children():
		child.queue_free()

	for member in members:
		var label := Label.new()
		label.text = "%s  Lv.%d  EXP %d" % [member.name, member.level, member.exp]
		label.theme_override_font_sizes["font_size"] = 16
		member_list.add_child(label)

func _on_quest_accepted(quest: Dictionary) -> void:
	$DialogBox.show_message("【%s】已接取！\n%s" % [quest.title, quest.description])

extends Node2D

const QUESTS_PATH := "res://data/quests.json"
const DECORATIONS_PATH := "res://data/decorations.json"
const DECORATION_GROUP := "guild_hall_decoration"

var quests: Array = []
var decorations: Array = []
var accepted_quest: Dictionary = {}
var selected_quest: Dictionary = {}
var total_xp := 0
var shown_decoration_ids: Array[String] = []
var queued_unlocks: Array[Dictionary] = []
var background_tween: Tween

@onready var background: Node = $World/FloorTileMapLayer
@onready var quest_panel: PanelContainer = $CanvasLayer/QuestPanel
@onready var quest_list: VBoxContainer = $CanvasLayer/QuestPanel/MarginContainer/VBoxContainer/QuestList
@onready var quest_title: Label = $CanvasLayer/QuestPanel/MarginContainer/VBoxContainer/QuestTitle
@onready var quest_description: Label = $CanvasLayer/QuestPanel/MarginContainer/VBoxContainer/QuestDescription
@onready var accept_button: Button = $CanvasLayer/QuestPanel/MarginContainer/VBoxContainer/ButtonRow/AcceptButton
@onready var complete_button: Button = $CanvasLayer/QuestPanel/MarginContainer/VBoxContainer/ButtonRow/CompleteButton
@onready var xp_label: Label = $CanvasLayer/Hud/XpLabel
@onready var unlock_panel: PanelContainer = $CanvasLayer/UnlockPanel
@onready var unlock_label: Label = $CanvasLayer/UnlockPanel/MarginContainer/UnlockLabel
@onready var unlock_timer: Timer = $UnlockTimer
@onready var decoration_root: Node2D = $World/YSortLayer
@onready var hero_actor: HeroActor = $World/YSortLayer/HeroActor
@onready var quest_board_object: QuestBoardObject = $World/YSortLayer/QuestBoardObject
@onready var parent_gate: ParentGateOverlay = $ParentGateOverlay

func _ready() -> void:
	quest_panel.visible = false
	unlock_panel.visible = false
	quests = _load_json_array(QUESTS_PATH)
	decorations = _load_json_array(DECORATIONS_PATH)
	_populate_quest_list()
	refresh_decorations(false)
	_update_xp_label()
	_update_background()
	hero_actor.setup_evolution(total_xp)
	accept_button.pressed.connect(_on_accept_pressed)
	complete_button.pressed.connect(_on_complete_pressed)
	unlock_timer.timeout.connect(_on_unlock_timer_timeout)
	quest_board_object.interacted.connect(_on_quest_board_interacted)
	parent_gate.verified.connect(_on_parent_gate_verified)
	parent_gate.cancelled.connect(_on_parent_gate_cancelled)

func _on_quest_board_interacted() -> void:
	quest_panel.visible = true

func _on_accept_pressed() -> void:
	if selected_quest.is_empty():
		return
	accepted_quest = selected_quest.duplicate(true)
	quest_title.text = "Accepted: %s" % accepted_quest.get("title", "Quest")
	complete_button.disabled = false

func _on_complete_pressed() -> void:
	if accepted_quest.is_empty():
		return
	complete_button.disabled = true
	var title := str(accepted_quest.get("title", "Quest"))
	var reward := _quest_reward(accepted_quest)
	parent_gate.show_gate(title, reward)

func _on_parent_gate_verified() -> void:
	total_xp += _quest_reward(accepted_quest)
	accepted_quest.clear()
	complete_button.disabled = true
	_update_xp_label()
	_update_background()
	hero_actor.setup_evolution(total_xp)
	refresh_decorations(true)

func _on_parent_gate_cancelled() -> void:
	complete_button.disabled = false

func refresh_decorations(show_unlock_feedback := true) -> void:
	for child in decoration_root.get_children():
		if child.is_in_group(DECORATION_GROUP):
			child.queue_free()
	for decoration in decorations:
		if total_xp < _decoration_unlock_xp(decoration):
			continue
		_spawn_decoration(decoration)
		var id := str(decoration.get("id", ""))
		if show_unlock_feedback and not shown_decoration_ids.has(id):
			_queue_decoration_unlock(decoration)
		if not shown_decoration_ids.has(id):
			shown_decoration_ids.append(id)

func _queue_decoration_unlock(decoration: Dictionary) -> void:
	queued_unlocks.append(decoration)
	if not unlock_panel.visible:
		_show_next_unlock()

func _show_next_unlock() -> void:
	if queued_unlocks.is_empty():
		unlock_panel.visible = false
		return
	var decoration := queued_unlocks.pop_front()
	unlock_label.text = "New guild comfort unlocked: %s" % _decoration_name(decoration)
	unlock_panel.visible = true
	if has_node("/root/SoundManager"):
		SoundManager.play_unlock_decor_sound()
	unlock_timer.start()

func _on_unlock_timer_timeout() -> void:
	_show_next_unlock()

func _populate_quest_list() -> void:
	for child in quest_list.get_children():
		child.queue_free()
	for quest in quests:
		var button := Button.new()
		button.text = "%s (+%s EXP)" % [quest.get("title", "Quest"), _quest_reward(quest)]
		button.pressed.connect(_select_quest.bind(quest))
		quest_list.add_child(button)
	if not quests.is_empty():
		_select_quest(quests[0])

func _select_quest(quest: Dictionary) -> void:
	selected_quest = quest
	quest_title.text = str(quest.get("title", "Quest"))
	quest_description.text = str(quest.get("description", "Choose a kind household quest."))
	accept_button.disabled = false

func _spawn_decoration(decoration: Dictionary) -> void:
	var node := DecorPlaceholder.new()
	node.add_to_group(DECORATION_GROUP)
	decoration_root.add_child(node)
	node.setup(decoration)
	var scene_position: Array = decoration.get("scene_position", [0, 0])
	node.position = Vector2(float(scene_position[0]), float(scene_position[1]))

func _update_xp_label() -> void:
	xp_label.text = "Guild XP: %s" % total_xp

func _update_background() -> void:
	var target := Color("#f2ddbf")
	if total_xp >= 60:
		target = Color("#d8c6f2")
	elif total_xp >= 30:
		target = Color("#c6e0f2")
	if background_tween != null:
		background_tween.kill()
	background_tween = create_tween()
	background_tween.tween_property(background, "floor_color", target, 0.4)

func _decoration_name(decoration: Dictionary) -> String:
	return str(decoration.get("name", decoration.get("display_name", "Decoration")))

func _decoration_unlock_xp(decoration: Dictionary) -> int:
	return int(decoration.get("unlock_xp", decoration.get("required_total_xp", 0)))

func _quest_reward(quest: Dictionary) -> int:
	return int(quest.get("xp_reward", quest.get("reward_exp", 0)))

func _load_json_array(path: String) -> Array:
	if not FileAccess.file_exists(path):
		return []
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Array else []

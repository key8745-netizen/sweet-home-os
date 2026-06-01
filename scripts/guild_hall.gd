extends Node2D

const QUESTS_PATH := "res://data/quests.json"
const DECORATIONS_PATH := "res://data/decorations.json"
const HERO_STAGES_PATH := "res://data/hero_evolution.json"
const DECORATION_GROUP := "guild_hall_decoration"

var quests: Array = []
var decorations: Array = []
var hero_stages: Array = []
var accepted_quest: Dictionary = {}
var selected_quest: Dictionary = {}
var total_xp := 0
var shown_decoration_ids: Array[String] = []
var queued_unlocks: Array[Dictionary] = []
var background_tween: Tween
var autosave_timer: Timer

@onready var background: GridWorld = $World/FloorTileMapLayer
@onready var quest_panel: PanelContainer = $CanvasLayer/QuestPanel
@onready var quest_list: VBoxContainer = $CanvasLayer/QuestPanel/MarginContainer/VBoxContainer/QuestList
@onready var quest_title: Label = $CanvasLayer/QuestPanel/MarginContainer/VBoxContainer/QuestTitle
@onready var quest_description: Label = $CanvasLayer/QuestPanel/MarginContainer/VBoxContainer/QuestDescription
@onready var accept_button: Button = $CanvasLayer/QuestPanel/MarginContainer/VBoxContainer/ButtonRow/AcceptButton
@onready var complete_button: Button = $CanvasLayer/QuestPanel/MarginContainer/VBoxContainer/ButtonRow/CompleteButton
@onready var xp_label: Label = $CanvasLayer/Hud/XpLabel
@onready var hero_status_label: Label = $CanvasLayer/Hud/HeroStatusLabel
@onready var help_button: Button = $CanvasLayer/Hud/HelpButton
@onready var help_panel: PanelContainer = $CanvasLayer/HelpPanel
@onready var help_close_button: Button = $CanvasLayer/HelpPanel/MarginContainer/VBoxContainer/CloseHelpButton
@onready var unlock_panel: PanelContainer = $CanvasLayer/UnlockPanel
@onready var unlock_label: Label = $CanvasLayer/UnlockPanel/MarginContainer/UnlockLabel
@onready var unlock_timer: Timer = $UnlockTimer
@onready var decoration_root: Node2D = $World/YSortLayer
@onready var hero_actor: HeroActor = $World/YSortLayer/HeroActor
@onready var quest_board_object: QuestBoardObject = $World/YSortLayer/QuestBoardObject
@onready var parent_gate_overlay: ParentGateOverlay = $ParentGateOverlay

func _ready() -> void:
	quest_panel.visible = false
	help_panel.visible = false
	unlock_panel.visible = false
	quests = _load_json_array(QUESTS_PATH)
	decorations = _load_json_array(DECORATIONS_PATH)
	hero_stages = _load_json_array(HERO_STAGES_PATH)
	_apply_save_data(SaveManager.load_game())
	_populate_quest_list()
	if not accepted_quest.is_empty():
		quest_title.text = "Accepted: %s" % accepted_quest.get("title", "Quest")
		complete_button.disabled = false
	refresh_decorations(false)
	_update_xp_label()
	_update_hero_status_label()
	_update_background()
	hero_actor.setup_evolution(total_xp)
	_setup_autosave_timer()
	accept_button.pressed.connect(_on_accept_pressed)
	complete_button.pressed.connect(_on_complete_pressed)
	help_button.pressed.connect(_on_help_pressed)
	help_close_button.pressed.connect(_on_help_close_pressed)
	unlock_timer.timeout.connect(_on_unlock_timer_timeout)
	quest_board_object.interacted.connect(_on_quest_board_interacted)
	parent_gate_overlay.verified.connect(_on_parent_gate_verified)
	parent_gate_overlay.cancelled.connect(_on_parent_gate_cancelled)

func _exit_tree() -> void:
	_save_progress()

func _on_quest_board_interacted() -> void:
	quest_panel.visible = true

func _on_help_pressed() -> void:
	help_panel.visible = true

func _on_help_close_pressed() -> void:
	help_panel.visible = false

func _on_accept_pressed() -> void:
	if selected_quest.is_empty():
		return
	accepted_quest = selected_quest.duplicate(true)
	quest_title.text = "Accepted: %s" % accepted_quest.get("title", "Quest")
	complete_button.disabled = false
	_save_progress()

func _on_complete_pressed() -> void:
	if accepted_quest.is_empty():
		return
	complete_button.disabled = true
	parent_gate_overlay.show_gate(str(accepted_quest.get("title", "Quest")), _quest_reward(accepted_quest))

func _on_parent_gate_verified() -> void:
	if accepted_quest.is_empty():
		complete_button.disabled = true
		return
	total_xp += _quest_reward(accepted_quest)
	accepted_quest.clear()
	complete_button.disabled = true
	_update_xp_label()
	_update_hero_status_label()
	_update_background()
	hero_actor.setup_evolution(total_xp)
	refresh_decorations(true)
	_save_progress()

func _on_parent_gate_cancelled() -> void:
	complete_button.disabled = accepted_quest.is_empty()

func refresh_decorations(show_unlock_feedback := true) -> void:
	for child in decoration_root.get_children():
		if child.is_in_group(DECORATION_GROUP):
			child.queue_free()
	for decoration in decorations:
		if total_xp < _decoration_unlock_xp(decoration):
			continue
		var decoration_node := _spawn_decoration(decoration)
		var id := str(decoration.get("id", ""))
		if show_unlock_feedback and not shown_decoration_ids.has(id):
			decoration_node.play_unlock_pop()
			_queue_decoration_unlock(decoration)
		if not shown_decoration_ids.has(id):
			shown_decoration_ids.append(id)
			if show_unlock_feedback:
				_save_progress()

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

func _spawn_decoration(decoration: Dictionary) -> DecorPlaceholder:
	var node := DecorPlaceholder.new()
	node.add_to_group(DECORATION_GROUP)
	decoration_root.add_child(node)
	node.setup(decoration)
	var scene_position: Array = decoration.get("scene_position", [0, 0])
	node.position = Vector2(float(scene_position[0]), float(scene_position[1]))
	return node

func _update_xp_label() -> void:
	xp_label.text = "Guild XP: %s" % total_xp

func _update_hero_status_label() -> void:
	var current_stage := _current_hero_stage()
	if current_stage.is_empty():
		hero_status_label.text = "Hero: Growing Helper"
		return
	var current_name := str(current_stage.get("display_name", current_stage.get("name", "Hero")))
	var next_stage := _next_hero_stage()
	if next_stage.is_empty():
		hero_status_label.text = "Hero: %s | Fully grown" % current_name
		return
	hero_status_label.text = "Hero: %s | Next: %s XP" % [current_name, int(next_stage.get("required_total_xp", 0))]

func _current_hero_stage() -> Dictionary:
	var current_stage: Dictionary = {}
	var current_required_xp := -1
	for stage in hero_stages:
		var required_xp := int(stage.get("required_total_xp", 0))
		if total_xp >= required_xp and required_xp >= current_required_xp:
			current_stage = stage
			current_required_xp = required_xp
	return current_stage

func _next_hero_stage() -> Dictionary:
	var next_stage: Dictionary = {}
	var next_required_xp := 2147483647
	for stage in hero_stages:
		var required_xp := int(stage.get("required_total_xp", 0))
		if required_xp > total_xp and required_xp < next_required_xp:
			next_stage = stage
			next_required_xp = required_xp
	return next_stage

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

func _setup_autosave_timer() -> void:
	autosave_timer = Timer.new()
	autosave_timer.wait_time = 30.0
	autosave_timer.autostart = true
	autosave_timer.timeout.connect(_save_progress)
	add_child(autosave_timer)

func _apply_save_data(save_data: Dictionary) -> void:
	total_xp = max(0, int(save_data.get("total_xp", 0)))
	shown_decoration_ids.clear()
	for raw_id in save_data.get("shown_decoration_ids", []):
		shown_decoration_ids.append(str(raw_id))
	if _should_reset_daily_quest(save_data):
		accepted_quest.clear()
	else:
		accepted_quest = _find_saved_quest(save_data.get("accepted_quest", {}))
	complete_button.disabled = accepted_quest.is_empty()

func _find_saved_quest(saved_quest) -> Dictionary:
	if not saved_quest is Dictionary or saved_quest.is_empty():
		return {}
	var saved_id := str(saved_quest.get("id", ""))
	for quest in quests:
		if str(quest.get("id", "")) == saved_id:
			return quest.duplicate(true)
	return {}

func _save_progress() -> void:
	SaveManager.save_game({
		"total_xp": total_xp,
		"accepted_quest": accepted_quest,
		"shown_decoration_ids": shown_decoration_ids,
		"last_play_date": _current_date_string(),
	})

func _should_reset_daily_quest(save_data: Dictionary) -> bool:
	var last_play_date := str(save_data.get("last_play_date", ""))
	return last_play_date != "" and last_play_date != _current_date_string()

func _current_date_string() -> String:
	var date := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [int(date.get("year", 0)), int(date.get("month", 0)), int(date.get("day", 0))]

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

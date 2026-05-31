## GuildHall — main scene controller for the Family Guild Board.
## Loads quests from data/quests.json, manages XP, decoration unlocks,
## and delegates character evolution to HeroActor.
extends Node2D

# ---------------------------------------------------------------------------
# Constants & paths
# ---------------------------------------------------------------------------
const QUESTS_PATH      := "res://data/quests.json"
const DECORATIONS_PATH := "res://data/decorations.json"
const SAVE_PATH        := "user://save_data.json"

# Background gradient colours across XP bands
const BG_COLOR_LOW    := Color("#f2ddbf")   # 0–29 XP
const BG_COLOR_MID    := Color("#c6e0f2")   # 30–59 XP
const BG_COLOR_HIGH   := Color("#d8c6f2")   # 60+ XP

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------
var _quests: Array          = []
var _decorations: Array     = []
var _quest_states: Dictionary = {}   # quest_id -> "available" | "accepted" | "completed"
var _total_xp: int          = 0
var _selected_quest_id: String = ""
var _shown_decoration_ids: Array[String] = []
var queued_unlocks: Array[Dictionary] = []

var background_tween: Tween = null

# ---------------------------------------------------------------------------
# Node references (populated in _ready)
# ---------------------------------------------------------------------------
@onready var _background:      ColorRect     = $Background
@onready var _quest_list:      VBoxContainer = $QuestList
@onready var _detail_panel:    Panel         = $DetailPanel
@onready var _quest_title:     Label         = $DetailPanel/VBoxContainer/QuestTitle
@onready var _quest_desc:      Label         = $DetailPanel/VBoxContainer/QuestDesc
@onready var _xp_reward_label: Label         = $DetailPanel/VBoxContainer/XPReward
@onready var _accept_button:   Button        = $DetailPanel/VBoxContainer/AcceptButton
@onready var _complete_button: Button        = $DetailPanel/VBoxContainer/CompleteButton
@onready var _xp_label:        Label         = $XPLabel
@onready var _unlock_panel:    Control       = $UnlockPanel
@onready var _unlock_label:    Label         = $UnlockPanel/UnlockLabel
@onready var _unlock_timer:    Timer         = $UnlockTimer
@onready var _hero_actor:      Node2D        = $HeroActor
@onready var _decorations_node: Node2D       = $Decorations
@onready var _boundaries:      Node2D        = $Boundaries
@onready var _quest_board:     Area2D        = $QuestBoardObject

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_setup_background()
	_load_data()
	_load_save()
	_populate_quest_list()
	_update_xp_label()
	_detail_panel.visible = false
	_unlock_panel.visible = false

	_accept_button.pressed.connect(_on_accept_pressed)
	_complete_button.pressed.connect(_on_complete_pressed)

	if _quest_board != null and _quest_board.has_signal("interacted"):
		_quest_board.interacted.connect(_on_quest_board_interacted)

	if _unlock_timer != null:
		_unlock_timer.wait_time = 2.0
		_unlock_timer.one_shot = true
		_unlock_timer.timeout.connect(_on_unlock_timer_timeout)

	# Trigger initial decoration unlock check (for XP = 0 starter items)
	refresh_decorations(false)

# ---------------------------------------------------------------------------
# Background tween
# ---------------------------------------------------------------------------

func _setup_background() -> void:
	if _background == null:
		return
	_background.color = _bg_color_for_xp(_total_xp)

func _bg_color_for_xp(xp: int) -> Color:
	if xp >= 60:
		return BG_COLOR_HIGH
	elif xp >= 30:
		return BG_COLOR_MID
	return BG_COLOR_LOW

func _tween_background(new_color: Color) -> void:
	if _background == null:
		return
	if background_tween != null and background_tween.is_valid():
		background_tween.kill()
	background_tween = create_tween()
	background_tween.tween_property(_background, "color", new_color, 0.4)

# ---------------------------------------------------------------------------
# Quest board interaction
# ---------------------------------------------------------------------------

func _on_quest_board_interacted() -> void:
	_detail_panel.visible = false
	_populate_quest_list()
	_quest_list.visible = true

# ---------------------------------------------------------------------------
# Data loading
# ---------------------------------------------------------------------------

func _load_data() -> void:
	_quests      = _read_json_array(QUESTS_PATH)
	_decorations = _read_json_array(DECORATIONS_PATH)

	for quest in _quests:
		var qid: String = quest.get("id", "")
		if qid != "" and not _quest_states.has(qid):
			_quest_states[qid] = "available"

func _read_json_array(path: String) -> Array:
	if not FileAccess.file_exists(path):
		push_warning("GuildHall: file not found: %s" % path)
		return []
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not (parsed is Array):
		push_error("GuildHall: failed to parse JSON array from %s" % path)
		return []
	return parsed

# ---------------------------------------------------------------------------
# Save / Load
# ---------------------------------------------------------------------------

func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	var data = JSON.parse_string(text)
	if data == null or not (data is Dictionary):
		return
	_total_xp = int(data.get("total_xp", 0))
	var states = data.get("quest_states", {})
	if states is Dictionary:
		_quest_states.merge(states, true)
	var shown = data.get("shown_decoration_ids", [])
	if shown is Array:
		for id in shown:
			if not _shown_decoration_ids.has(id):
				_shown_decoration_ids.append(id)

func _save() -> void:
	var data := {
		"total_xp":              _total_xp,
		"quest_states":          _quest_states,
		"shown_decoration_ids":  _shown_decoration_ids,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

# ---------------------------------------------------------------------------
# Quest list UI
# ---------------------------------------------------------------------------

func _populate_quest_list() -> void:
	for child in _quest_list.get_children():
		child.queue_free()

	for quest in _quests:
		var qid: String  = quest.get("id", "")
		var title: String = quest.get("title", "Quest")
		var state: String = _quest_states.get(qid, "available")

		var btn := Button.new()
		btn.text = "%s [%s]" % [title, _state_label(state)]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_quest_button_pressed.bind(qid))
		_quest_list.add_child(btn)

func _state_label(state: String) -> String:
	match state:
		"accepted":  return "進行中"
		"completed": return "完成"
		_:           return "可接取"

# ---------------------------------------------------------------------------
# Quest button handler
# ---------------------------------------------------------------------------

func _on_quest_button_pressed(quest_id: String) -> void:
	_selected_quest_id = quest_id
	var quest := _find_quest(quest_id)
	if quest.is_empty():
		return

	_quest_title.text     = quest.get("title", "")
	_quest_desc.text      = quest.get("description", "")
	_xp_reward_label.text = "獎勵 XP：%d" % int(quest.get("xp_reward", 0))

	var state: String = _quest_states.get(quest_id, "available")
	_accept_button.visible   = (state == "available")
	_complete_button.visible = (state == "accepted")
	_detail_panel.visible    = true

func _find_quest(quest_id: String) -> Dictionary:
	for q in _quests:
		if q.get("id", "") == quest_id:
			return q
	return {}

# ---------------------------------------------------------------------------
# Accept / Complete handlers
# ---------------------------------------------------------------------------

func _on_accept_pressed() -> void:
	if _selected_quest_id == "":
		return
	_quest_states[_selected_quest_id] = "accepted"
	SoundManager.play_quest_accept_sound()
	_refresh_quest_list()
	_on_quest_button_pressed(_selected_quest_id)
	_save()

func _on_complete_pressed() -> void:
	if _selected_quest_id == "":
		return
	var quest := _find_quest(_selected_quest_id)
	if quest.is_empty():
		return

	var old_xp := _total_xp
	var reward: int = int(quest.get("xp_reward", 0))
	_total_xp += reward
	_quest_states[_selected_quest_id] = "completed"

	_update_xp_label()
	_refresh_quest_list()
	_detail_panel.visible = false

	# Tween background if XP band changed
	_tween_background(_bg_color_for_xp(_total_xp))

	# Notify HeroActor
	if _hero_actor != null and _hero_actor.has_method("setup_evolution"):
		_hero_actor.setup_evolution(_total_xp)

	refresh_decorations(true)
	_save()

# ---------------------------------------------------------------------------
# XP label
# ---------------------------------------------------------------------------

func _update_xp_label() -> void:
	_xp_label.text = "XP: %d" % _total_xp

# ---------------------------------------------------------------------------
# Decoration system
# ---------------------------------------------------------------------------

func refresh_decorations(show_unlock_feedback := true) -> void:
	for decor in _decorations:
		var did: String    = decor.get("id", "")
		var threshold: int = int(decor.get("required_total_xp", 0))

		if _shown_decoration_ids.has(did):
			continue
		if _total_xp >= threshold:
			_shown_decoration_ids.append(did)
			_spawn_decoration(decor)
			if show_unlock_feedback:
				_queue_decoration_unlock(decor)

	if show_unlock_feedback and not queued_unlocks.is_empty():
		_show_next_unlock()

func _spawn_decoration(decoration: Dictionary) -> void:
	if _decorations_node == null:
		return
	var node := DecorPlaceholder.new()
	node.call_deferred("setup", decoration)
	var pos_arr = decoration.get("scene_position", [0, 0])
	if pos_arr is Array and pos_arr.size() >= 2:
		node.position = Vector2(float(pos_arr[0]), float(pos_arr[1]))
	_decorations_node.add_child(node)

func _queue_decoration_unlock(decoration: Dictionary) -> void:
	queued_unlocks.append(decoration)

func _show_next_unlock() -> void:
	if queued_unlocks.is_empty():
		return
	var decor: Dictionary = queued_unlocks.pop_front()
	_unlock_label.text = "New guild comfort unlocked!\n%s" % decor.get("display_name", "")
	_unlock_panel.visible = true
	SoundManager.play_unlock_decor_sound()
	if _unlock_timer != null:
		_unlock_timer.start()

func _on_unlock_timer_timeout() -> void:
	_unlock_panel.visible = false
	if not queued_unlocks.is_empty():
		_show_next_unlock()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _refresh_quest_list() -> void:
	_populate_quest_list()

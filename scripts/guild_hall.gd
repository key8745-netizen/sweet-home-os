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

# Background gradient colours (dark blue → deep purple, JRPG style)
const BG_TOP_COLOR    := Color(0.06, 0.06, 0.18)
const BG_BOTTOM_COLOR := Color(0.18, 0.06, 0.28)

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------
var _quests: Array          = []
var _decorations: Array     = []
var _quest_states: Dictionary = {}   # quest_id -> "available" | "accepted" | "completed"
var _total_xp: int          = 0
var _selected_quest_id: String = ""
var _unlocked_decor_ids: Array[String] = []
var _decor_unlock_queue: Array[Dictionary] = []

# ---------------------------------------------------------------------------
# Node references (populated in _ready)
# ---------------------------------------------------------------------------
@onready var _background:     ColorRect  = $Background
@onready var _quest_list:     VBoxContainer = $QuestList
@onready var _detail_panel:   Panel      = $DetailPanel
@onready var _quest_title:    Label      = $DetailPanel/VBoxContainer/QuestTitle
@onready var _quest_desc:     Label      = $DetailPanel/VBoxContainer/QuestDesc
@onready var _xp_reward_label: Label     = $DetailPanel/VBoxContainer/XPReward
@onready var _accept_button:  Button     = $DetailPanel/VBoxContainer/AcceptButton
@onready var _complete_button: Button    = $DetailPanel/VBoxContainer/CompleteButton
@onready var _xp_label:       Label      = $XPLabel
@onready var _unlock_overlay: Control    = $UnlockOverlay
@onready var _hero_actor:     Node2D     = $HeroActor

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
	_unlock_overlay.visible = false

	_accept_button.pressed.connect(_on_accept_pressed)
	_complete_button.pressed.connect(_on_complete_pressed)

	# Trigger initial decoration unlock check (for XP = 0 starter items)
	_check_decoration_unlocks(_total_xp, -1)

# ---------------------------------------------------------------------------
# Background
# ---------------------------------------------------------------------------

func _setup_background() -> void:
	if _background == null:
		return
	# Use a ShaderMaterial-free approach: set a gradient via a plain ColorRect
	# tinted at the top colour; a second overlay rect provides the gradient feel.
	_background.color = BG_TOP_COLOR

	# Create a simple gradient overlay using a second ColorRect with modulation
	var overlay := ColorRect.new()
	overlay.color = BG_BOTTOM_COLOR
	overlay.modulate.a = 0.5
	overlay.size = _background.size
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(overlay)

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
	var unlocked = data.get("unlocked_decor_ids", [])
	if unlocked is Array:
		for id in unlocked:
			if not _unlocked_decor_ids.has(id):
				_unlocked_decor_ids.append(id)

func _save() -> void:
	var data := {
		"total_xp":         _total_xp,
		"quest_states":     _quest_states,
		"unlocked_decor_ids": _unlocked_decor_ids,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

# ---------------------------------------------------------------------------
# Quest list UI
# ---------------------------------------------------------------------------

func _populate_quest_list() -> void:
	# Clear existing buttons
	for child in _quest_list.get_children():
		child.queue_free()

	for quest in _quests:
		var qid: String  = quest.get("id", "")
		var title: String = quest.get("title", "Quest")
		var diff: int    = int(quest.get("difficulty", 1))
		var state: String = _quest_states.get(qid, "available")

		var btn := Button.new()
		btn.text = "%s %s [%s]" % [_difficulty_stars(diff), title, _state_label(state)]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_quest_button_pressed.bind(qid))
		_quest_list.add_child(btn)

func _difficulty_stars(diff: int) -> String:
	return "★".repeat(clamp(diff, 1, 3)) + "☆".repeat(3 - clamp(diff, 1, 3))

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

	_quest_title.text    = quest.get("title", "")
	_quest_desc.text     = quest.get("description", "")
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
	# Re-open detail to update buttons
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

	# Notify HeroActor
	if _hero_actor != null and _hero_actor.has_method("setup_evolution"):
		_hero_actor.setup_evolution(_total_xp)

	_check_decoration_unlocks(_total_xp, old_xp)
	_save()

# ---------------------------------------------------------------------------
# XP label
# ---------------------------------------------------------------------------

func _update_xp_label() -> void:
	_xp_label.text = "XP: %d" % _total_xp

# ---------------------------------------------------------------------------
# Decoration unlocks
# ---------------------------------------------------------------------------

func _check_decoration_unlocks(new_xp: int, old_xp: int) -> void:
	for decor in _decorations:
		var did: String  = decor.get("id", "")
		var threshold: int = int(decor.get("unlock_xp", 0))

		if _unlocked_decor_ids.has(did):
			continue
		if new_xp >= threshold and (old_xp < threshold or old_xp < 0):
			_unlocked_decor_ids.append(did)
			_decor_unlock_queue.append(decor)

	_process_unlock_queue()

func _process_unlock_queue() -> void:
	if _decor_unlock_queue.is_empty():
		return
	var decor: Dictionary = _decor_unlock_queue.pop_front()
	_show_unlock_overlay(decor)

func _show_unlock_overlay(decor: Dictionary) -> void:
	_unlock_overlay.visible = true

	# Remove previous overlay children
	for child in _unlock_overlay.get_children():
		child.queue_free()

	# Build a simple announcement panel
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	_unlock_overlay.add_child(panel)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var header := Label.new()
	header.text = "🏆 裝飾解鎖！"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 24)
	vbox.add_child(header)

	var name_lbl := Label.new()
	name_lbl.text = decor.get("name", "")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 20)
	vbox.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = decor.get("description", "")
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc_lbl)

	var close_btn := Button.new()
	close_btn.text = "太棒了！"
	close_btn.pressed.connect(_on_overlay_closed)
	vbox.add_child(close_btn)

	SoundManager.play_unlock_decor_sound()

	# Auto-dismiss after 4 seconds as a safety net
	get_tree().create_timer(4.0).timeout.connect(_on_overlay_closed)

func _on_overlay_closed() -> void:
	_unlock_overlay.visible = false
	for child in _unlock_overlay.get_children():
		child.queue_free()
	# Process next in queue
	_process_unlock_queue()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _refresh_quest_list() -> void:
	_populate_quest_list()

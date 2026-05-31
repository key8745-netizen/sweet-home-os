extends Control

const QUESTS_PATH := "res://data/quests.json"
const DECORATIONS_PATH := "res://data/decorations.json"
const DECOR_PLACEHOLDER_SCRIPT := preload("res://scripts/decor_placeholder.gd")
const BACKGROUND_LEVELS := [
	{"xp": 0,    "color": Color(0.09, 0.08, 0.14)},
	{"xp": 500,  "color": Color(0.13, 0.11, 0.21)},
	{"xp": 1500, "color": Color(0.18, 0.15, 0.27)},
	{"xp": 3500, "color": Color(0.24, 0.19, 0.32)},
]

var quests: Array = []
var decorations: Array = []
var visible_decoration_ids: Array[String] = []
var queued_unlocks: Array[Dictionary] = []
var selected_quest: Dictionary = {}
var accepted_quest: Dictionary = {}
var total_xp := 0
var unlock_overlay_active := false
var background_tween: Tween

@onready var background: ColorRect = %Background
@onready var decor_container: Node2D = %DecorContainer
@onready var quest_list: VBoxContainer = %QuestList
@onready var detail_title: Label = %DetailTitle
@onready var detail_body: RichTextLabel = %DetailBody
@onready var accept_button: Button = %AcceptButton
@onready var status_label: Label = %StatusLabel
@onready var complete_button: Button = %CompleteButton
@onready var xp_label: Label = %XpLabel
@onready var unlock_panel: PanelContainer = %UnlockPanel
@onready var unlock_label: Label = %UnlockLabel
@onready var unlock_timer: Timer = %UnlockTimer
@onready var hero_actor: CharacterBody2D = %HeroActor


func _ready() -> void:
	accept_button.pressed.connect(_on_accept_pressed)
	complete_button.pressed.connect(_on_complete_pressed)
	unlock_timer.timeout.connect(_hide_unlock_overlay)
	complete_button.disabled = true
	unlock_panel.visible = false
	load_quests()
	load_decorations()
	populate_quest_list()
	_update_xp_label()
	refresh_decorations(false)
	if hero_actor.has_method("setup_evolution"):
		hero_actor.setup_evolution(0)
	if not quests.is_empty():
		select_quest(quests[0])


func load_quests() -> void:
	quests = []
	if not FileAccess.file_exists(QUESTS_PATH):
		status_label.text = "找不到任務資料：%s" % QUESTS_PATH
		push_warning(status_label.text)
		return
	var file := FileAccess.open(QUESTS_PATH, FileAccess.READ)
	if file == null:
		status_label.text = "無法開啟任務資料。"
		push_warning("Unable to open quest data: %s" % QUESTS_PATH)
		return
	var parsed_data = JSON.parse_string(file.get_as_text())
	if not parsed_data is Dictionary:
		status_label.text = "任務資料格式錯誤。"
		push_warning("Quest data must be a JSON object.")
		return
	var loaded_quests = parsed_data.get("quests", [])
	if not loaded_quests is Array:
		status_label.text = "任務資料缺少 quests 陣列。"
		push_warning("Quest data must include a quests array.")
		return
	quests = loaded_quests
	status_label.text = "已載入 %d 張任務卡。" % quests.size()


func load_decorations() -> void:
	decorations = []
	if not FileAccess.file_exists(DECORATIONS_PATH):
		push_warning("Decoration data file is missing: %s" % DECORATIONS_PATH)
		return
	var file := FileAccess.open(DECORATIONS_PATH, FileAccess.READ)
	if file == null:
		push_warning("Unable to open decoration data file: %s" % DECORATIONS_PATH)
		return
	var parsed_data = JSON.parse_string(file.get_as_text())
	if not parsed_data is Dictionary:
		push_warning("Decoration data must be a JSON object.")
		return
	var loaded_decorations = parsed_data.get("decorations", [])
	if not loaded_decorations is Array:
		push_warning("Decoration data must include a decorations array.")
		return
	decorations = loaded_decorations


func populate_quest_list() -> void:
	for child in quest_list.get_children():
		child.queue_free()
	for quest in quests:
		if not quest is Dictionary:
			continue
		var quest_button := Button.new()
		quest_button.text = "%s  +%d XP" % [quest.get("title", "未命名任務"), int(quest.get("xp_reward", 0))]
		quest_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		quest_button.pressed.connect(select_quest.bind(quest))
		quest_list.add_child(quest_button)


func select_quest(quest: Dictionary) -> void:
	selected_quest = quest
	detail_title.text = str(quest.get("title", "未命名任務"))
	detail_body.text = _format_quest_detail(quest)
	accept_button.disabled = false
	status_label.text = "選擇任務後，先離開螢幕完成真實家務，再回來回報。"


func _format_quest_detail(quest: Dictionary) -> String:
	var t := ""
	t += "[b]區域：[/b] %s\n" % quest.get("area", "home")
	t += "[b]難度：[/b] %s\n" % quest.get("difficulty", "easy")
	t += "[b]預估時間：[/b] %d 分鐘\n" % int(quest.get("estimated_minutes", 5))
	t += "[b]獎勵：[/b] %d XP\n\n" % int(quest.get("xp_reward", 0))
	t += str(quest.get("description", ""))
	t += "\n\n[color=#f4c95d]家長提示：%s[/color]" % quest.get("parent_tip", "用鼓勵確認孩子的努力。")
	return t


func _on_accept_pressed() -> void:
	if selected_quest.is_empty():
		return
	accepted_quest = selected_quest.duplicate()
	complete_button.disabled = false
	status_label.text = "已接受「%s」！完成後請找家長一起確認，再按完成回報。" % accepted_quest.get("title", "任務")


func _on_complete_pressed() -> void:
	if accepted_quest.is_empty():
		return
	var earned_xp := int(accepted_quest.get("xp_reward", 0))
	total_xp += earned_xp
	status_label.text = "完成「%s」！公會獲得 %d XP，謝謝你的照顧。" % [accepted_quest.get("title", "任務"), earned_xp]
	accepted_quest = {}
	complete_button.disabled = true
	_update_xp_label()
	refresh_decorations(true)
	if hero_actor.has_method("setup_evolution"):
		hero_actor.setup_evolution(total_xp)


func refresh_decorations(show_unlock_feedback := true) -> void:
	var previous_ids := visible_decoration_ids.duplicate()
	visible_decoration_ids = []
	_update_background(show_unlock_feedback)
	for child in decor_container.get_children():
		child.queue_free()
	for decoration in decorations:
		if not decoration is Dictionary:
			continue
		if total_xp < int(decoration.get("required_total_xp", 0)):
			continue
		var decor := Node2D.new()
		decor.set_script(DECOR_PLACEHOLDER_SCRIPT)
		decor_container.add_child(decor)
		decor.setup(decoration)
		var did := str(decoration.get("id", decoration.get("name", "decor")))
		visible_decoration_ids.append(did)
		if show_unlock_feedback and not previous_ids.has(did):
			_queue_decoration_unlock(decoration)


func _queue_decoration_unlock(decoration: Dictionary) -> void:
	queued_unlocks.append(decoration)
	if not unlock_overlay_active:
		_show_next_decoration_unlock()


func _show_next_decoration_unlock() -> void:
	if queued_unlocks.is_empty():
		unlock_overlay_active = false
		unlock_panel.visible = false
		return
	var decoration: Dictionary = queued_unlocks.pop_front()
	var decor_name := str(decoration.get("name", decoration.get("id", "新裝飾")))
	var narration := str(decoration.get("narration", ""))
	unlock_overlay_active = true
	unlock_label.text = "恭喜獲得：%s！\n%s" % [decor_name, narration]
	unlock_panel.visible = true
	unlock_timer.start()
	_play_unlock_sound()


func _hide_unlock_overlay() -> void:
	unlock_panel.visible = false
	unlock_overlay_active = false
	_show_next_decoration_unlock()


func _update_xp_label() -> void:
	xp_label.text = "Guild XP: %d" % total_xp


func _update_background(animate := true) -> void:
	var target_color := _get_background_color(total_xp)
	if not animate:
		background.color = target_color
		return
	if background_tween != null and background_tween.is_valid():
		background_tween.kill()
	background_tween = create_tween()
	background_tween.tween_property(background, "color", target_color, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _get_background_color(p_total_xp: int) -> Color:
	var selected_color: Color = BACKGROUND_LEVELS[0]["color"]
	for index in range(BACKGROUND_LEVELS.size() - 1):
		var cur: Dictionary = BACKGROUND_LEVELS[index]
		var nxt: Dictionary = BACKGROUND_LEVELS[index + 1]
		var cur_xp := int(cur["xp"])
		var nxt_xp := int(nxt["xp"])
		if p_total_xp >= cur_xp and p_total_xp < nxt_xp:
			var progress := float(p_total_xp - cur_xp) / float(nxt_xp - cur_xp)
			return cur["color"].lerp(nxt["color"], progress)
		selected_color = nxt["color"]
	return selected_color


func _play_unlock_sound() -> void:
	var sound_manager = get_node_or_null("/root/SoundManager")
	if sound_manager != null and sound_manager.has_method("play_unlock_decor_sound"):
		sound_manager.play_unlock_decor_sound()

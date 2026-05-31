extends Control

const QUESTS_PATH = "res://data/quests.json"

var quests: Array = []
var selected_quest: Dictionary = {}

@onready var quest_list = $QuestBoard/QuestList
@onready var quest_title = $QuestDetail/QuestTitle
@onready var quest_desc = $QuestDetail/QuestDesc
@onready var quest_meta = $QuestDetail/QuestMeta
@onready var parent_tip = $QuestDetail/ParentTip
@onready var accept_btn = $QuestDetail/AcceptButton
@onready var status_bar = $StatusBar


func _ready() -> void:
	_load_quests()
	_populate_quest_board()
	accept_btn.pressed.connect(_on_accept_pressed)
	_set_detail_visible(false)


func _load_quests() -> void:
	var file = FileAccess.open(QUESTS_PATH, FileAccess.READ)
	if not file:
		push_error("無法讀取任務資料：" + QUESTS_PATH)
		return
	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("任務 JSON 解析失敗")
		return
	quests = json.get_data().get("quests", [])


func _populate_quest_board() -> void:
	for child in quest_list.get_children():
		child.queue_free()

	for quest in quests:
		var btn = Button.new()
		var stars = "★".repeat(quest.get("difficulty", 1))
		btn.text = "[%s] %s  %s" % [quest.get("area", ""), quest.get("title", ""), stars]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_quest_selected.bind(quest))
		quest_list.add_child(btn)


func _on_quest_selected(quest: Dictionary) -> void:
	selected_quest = quest
	quest_title.text = quest.get("title", "")
	quest_desc.text = quest.get("description", "")
	quest_meta.text = "地點：%s　難度：%s　預計 %d 分鐘　獎勵 %d XP" % [
		quest.get("area", ""),
		"★".repeat(quest.get("difficulty", 1)),
		quest.get("estimated_minutes", 0),
		quest.get("xp_reward", 0)
	]
	parent_tip.text = "📋 家長提示：" + quest.get("parent_tip", "")
	_set_detail_visible(true)
	status_bar.text = "選擇了任務：" + quest.get("title", "")


func _on_accept_pressed() -> void:
	if selected_quest.is_empty():
		return
	status_bar.text = "✅ 已接受任務「%s」！完成後請告知家長確認。" % selected_quest.get("title", "")
	accept_btn.disabled = true
	accept_btn.text = "任務進行中…"


func _set_detail_visible(visible: bool) -> void:
	quest_title.visible = visible
	quest_desc.visible = visible
	quest_meta.visible = visible
	parent_tip.visible = visible
	accept_btn.visible = visible

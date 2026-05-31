extends Control

const QUESTS_PATH := "res://data/quests.json"

var quests: Array = []
var selected_quest: Dictionary = {}

@onready var quest_list: VBoxContainer = %QuestList
@onready var detail_title: Label = %DetailTitle
@onready var detail_desc: Label = %DetailDesc
@onready var detail_meta: Label = %DetailMeta
@onready var parent_tip: Label = %ParentTip
@onready var accept_btn: Button = %AcceptButton
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	load_quests()
	populate_quest_list()
	accept_btn.pressed.connect(_on_accept_pressed)
	_set_detail_visible(false)


func load_quests() -> void:
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


func populate_quest_list() -> void:
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
	detail_title.text = quest.get("title", "")
	detail_desc.text = quest.get("description", "")
	detail_meta.text = "地點：%s　難度：%s　預計 %d 分鐘　獎勵 %d XP" % [
		quest.get("area", ""),
		"★".repeat(quest.get("difficulty", 1)),
		quest.get("estimated_minutes", 0),
		quest.get("xp_reward", 0)
	]
	parent_tip.text = "📋 家長提示：" + quest.get("parent_tip", "")
	_set_detail_visible(true)
	status_label.text = "選擇了任務：" + quest.get("title", "")


func _on_accept_pressed() -> void:
	if selected_quest.is_empty():
		return
	status_label.text = "✅ 已接受任務「%s」！完成後請告知家長確認。" % selected_quest.get("title", "")
	accept_btn.disabled = true
	accept_btn.text = "任務進行中…"


func _set_detail_visible(visible: bool) -> void:
	detail_title.visible = visible
	detail_desc.visible = visible
	detail_meta.visible = visible
	parent_tip.visible = visible
	accept_btn.visible = visible

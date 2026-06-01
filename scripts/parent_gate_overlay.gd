extends CanvasLayer
class_name ParentGateOverlay

signal verified
signal cancelled

@export var parent_pin := "1234"

@onready var quest_context_label: Label = $Dimmer/PanelContainer/MarginContainer/VBoxContainer/QuestContextLabel
@onready var prompt_label: Label = $Dimmer/PanelContainer/MarginContainer/VBoxContainer/PromptLabel
@onready var pin_input: LineEdit = $Dimmer/PanelContainer/MarginContainer/VBoxContainer/PinInput
@onready var feedback_label: Label = $Dimmer/PanelContainer/MarginContainer/VBoxContainer/FeedbackLabel
@onready var confirm_button: Button = $Dimmer/PanelContainer/MarginContainer/VBoxContainer/ButtonRow/ConfirmButton
@onready var cancel_button: Button = $Dimmer/PanelContainer/MarginContainer/VBoxContainer/ButtonRow/CancelButton


func _ready() -> void:
	visible = false
	pin_input.text_submitted.connect(_on_pin_submitted)
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)


func show_gate(quest_title: String = "Quest", xp_reward: int = 0) -> void:
	quest_context_label.text = "家長確認：%s / +%s XP" % [quest_title, xp_reward]
	prompt_label.text = "請家長輸入 PIN，確認現實任務已完成。"
	feedback_label.text = "預設測試 PIN：1234。之後可接到設定或本地存檔。"
	feedback_label.modulate = Color("#f7e6c4")
	pin_input.clear()
	pin_input.modulate = Color.WHITE
	visible = true
	pin_input.grab_focus()


func _on_pin_submitted(_text: String) -> void:
	_on_confirm_pressed()


func _on_confirm_pressed() -> void:
	if pin_input.text.strip_edges() == parent_pin:
		verified.emit()
		visible = false
		return
	_show_error_feedback()


func _show_error_feedback() -> void:
	feedback_label.text = "PIN 不正確，請家長再試一次。"
	feedback_label.modulate = Color("#ff8a80")
	pin_input.clear()
	pin_input.grab_focus()
	var tween := create_tween()
	tween.tween_property(pin_input, "modulate", Color("#ff8a80"), 0.08)
	tween.tween_property(pin_input, "modulate", Color.WHITE, 0.12)


func _on_cancel_pressed() -> void:
	cancelled.emit()
	visible = false

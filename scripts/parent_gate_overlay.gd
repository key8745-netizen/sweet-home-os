extends CanvasLayer
class_name ParentGateOverlay

signal verified
signal cancelled

@onready var pin_input: LineEdit = $PanelContainer/VBoxContainer/PinInput
@onready var confirm_button: Button = $PanelContainer/VBoxContainer/ButtonRow/ConfirmButton
@onready var cancel_button: Button = $PanelContainer/VBoxContainer/ButtonRow/CancelButton

const PARENT_PIN := "1234"

func _ready() -> void:
	visible = false
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

func show_gate() -> void:
	pin_input.text = ""
	visible = true
	pin_input.grab_focus()

func _on_confirm_pressed() -> void:
	if pin_input.text == PARENT_PIN:
		visible = false
		verified.emit()
	else:
		pin_input.text = ""
		pin_input.placeholder_text = "Incorrect PIN — try again"

func _on_cancel_pressed() -> void:
	visible = false
	cancelled.emit()

extends CanvasLayer
class_name ParentGateOverlay

signal verified
signal cancelled

@onready var pin_input: LineEdit = $Dimmer/PanelContainer/MarginContainer/VBoxContainer/PinInput
@onready var confirm_button: Button = $Dimmer/PanelContainer/MarginContainer/VBoxContainer/ButtonRow/ConfirmButton
@onready var cancel_button: Button = $Dimmer/PanelContainer/MarginContainer/VBoxContainer/ButtonRow/CancelButton

const PARENT_PIN := "1234"

func _ready() -> void:
	visible = false
	if confirm_button:
		confirm_button.pressed.connect(_on_confirm_pressed)
	else:
		push_warning("ParentGateOverlay: ConfirmButton not found")
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_pressed)
	else:
		push_warning("ParentGateOverlay: CancelButton not found")

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

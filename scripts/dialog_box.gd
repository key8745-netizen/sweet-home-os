extends Control

func _ready() -> void:
	hide()

func show_message(text: String) -> void:
	$DialogPanel/DialogText.text = text
	show()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		hide()
		get_viewport().set_input_as_handled()

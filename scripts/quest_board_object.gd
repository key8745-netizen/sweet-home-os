extends Area2D
class_name QuestBoardObject

signal interacted

@export var prompt_text := "Read the quest board"

func interact(_hero: Node = null) -> void:
	interacted.emit()

func get_interact_prompt() -> String:
	return prompt_text

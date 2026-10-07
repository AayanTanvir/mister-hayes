class_name ReadAction
extends InteractAction


@export_multiline var text: String = ""

var _reading := false


func get_prompt() -> String:
	return "[E] Read"


func execute(_k: ActionKey) -> void:
	GameManager.ui.text_viewer.show_text(text)
	_reading = true

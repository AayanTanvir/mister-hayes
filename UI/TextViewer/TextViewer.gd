class_name TextViewer
extends CanvasLayer

@onready var label: RichTextLabel = %RichTextLabel


func _ready() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("esc"):
		GameManager.paused_interact_mode(false)
		close()


func show_text(text: String):
	GameManager.paused_interact_mode(true)
	label.text = text
	show()


func close():
	label.text = ""
	hide()

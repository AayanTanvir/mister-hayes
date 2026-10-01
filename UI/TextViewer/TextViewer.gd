class_name TextViewer
extends CanvasLayer

@onready var label: RichTextLabel = %RichTextLabel

func _ready() -> void:
	hide()


func show_text(text: String):
	GameManager.set_interact_mode(true)
	label.text = text
	show()


func close():
	GameManager.set_interact_mode(false)
	label.text = ""
	hide()

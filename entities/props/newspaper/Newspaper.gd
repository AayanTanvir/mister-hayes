extends InspectComponent

@export_multiline var text: String = "[b][font_size=18]THE NEWBURKE TIMES[/font_size][/b]

[b][font_size=16]RIPEYE SLAIN: SERIAL KILLER'S REIGN ENDS AT LAST[/font_size][/b]

Detective Ethan Hayes closes the case after a months-long manhunt

Authorities confirmed Thursday that the killer known only as the \"Ripeye\" is dead, following a confrontation with Detective Ethan Hayes. Hayes, who led the investigation since early this year refused to comment on the circumstances.

\"Newburke can rest easy,\" said Hayes's partner, Detective Marcus. \"Ethan didn't stop until it was over.\""

var _reading := false


func _ready() -> void:
	extended_prompt = "[E] Read"
	
	super._ready()


func _unhandled_input(event: InputEvent) -> void:
	super._unhandled_input(event)
	
	if _reading and event is InputEventKey and event.is_action_pressed("esc"):
		GameManager.ui.text_viewer.close()


func interact(interact_key: InteractableComponent.INTERACT_KEY) -> void:
	if interact_key == InteractableComponent.INTERACT_KEY.E:
		GameManager.ui.text_viewer.show_text(text)
		_reading = true
	
	super.interact(interact_key)

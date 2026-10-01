extends InspectComponent

@export_multiline var newspaper_text: String
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
		GameManager.ui.text_viewer.show_text(newspaper_text)
		_reading = true
	
	super.interact(interact_key)

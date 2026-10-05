## Basic class to implement inspecting to a object. Use super._ready and super.interact for this to take
## effect in inheriting scripts
class_name InspectComponent
extends InteractableComponent

@export var inspect_model: PackedScene  ## Model mesh without collision
@export var inspect_key: InteractableComponent.INTERACT_KEY = InteractableComponent.INTERACT_KEY.F
@export var inspect_prompt := "[F] Inspect"

var extended_prompt := ""	## Add other prompts to this variable


func _ready() -> void:
	if not interact_keys.has(InteractableComponent.INTERACT_KEY.F):
		printerr("[F] INSPECT INTERACT KEY NOT ASSIGNED")
	prompt = extended_prompt + "\n" + inspect_prompt


func interact(interact_key: INTERACT_KEY) -> void:
	if interact_key == inspect_key:
		GameManager.set_interact_mode(true)
		GameManager.ui.inspection_viewer.open(inspect_model)

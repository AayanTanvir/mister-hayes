## Basic class to implement inspecting to a object. Use super._ready and super.interact for this to take
## effect in inheriting scripts
class_name InspectComponent
extends InteractableComponent

@export var inspect_model: PackedScene  ## Model mesh without collision
@export var inspect_key: InteractableComponent.INTERACT_KEY = InteractableComponent.INTERACT_KEY.F
@export var inspect_prompt := "[F] Inspect"

var extended_prompt := ""	## Add other prompts to this variable
var _inspecting := false


func _ready() -> void:
	if not interact_keys.has(InteractableComponent.INTERACT_KEY.F):
		printerr("[F] INSPECT INTERACT KEY NOT ASSIGNED")
	prompt = extended_prompt + "\n" + inspect_prompt
	process_mode = Node.PROCESS_MODE_ALWAYS
	


func interact(interact_key: INTERACT_KEY) -> void:
	if interact_key == inspect_key:
		_set_inspect(true)


func _unhandled_input(event: InputEvent) -> void:
	if _inspecting and event is InputEventKey and event.is_action_pressed("esc"):
		_set_inspect(false)


func _set_inspect(enable: bool):
	GameManager.set_interact_mode(enable)
	_inspecting = enable
	if enable:
		GameManager.ui.inspection_viewer.open(inspect_model)
	else:
		GameManager.ui.inspection_viewer.close()

class_name InspectAction
extends InteractAction

@export var inspect_model: PackedScene
@export var _prompt := "[F] Inspect"


func _init() -> void:
	key = ActionKey.F


func get_prompt() -> String:
	return _prompt


func execute(_k: ActionKey) -> void:
	GameManager.ui.inspection_viewer.open(inspect_model)

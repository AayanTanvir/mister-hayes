class_name InspectComponent
extends Node3D

@export var inspect_scene: PackedScene  ## Model mesh without collision

var _inspecting := false


func _unhandled_input(event: InputEvent) -> void:
	if not _inspecting or event is not InputEventKey:
		return
	
	if event.is_action_pressed("interact_F"):
		GameManager.set_inspection_mode(false)
		GameManager.ui.inspection_viewer.close()
		_inspecting = false


func inspect():
	GameManager.set_inspection_mode(true)
	GameManager.ui.inspection_viewer.open(inspect_scene)
	_inspecting = true

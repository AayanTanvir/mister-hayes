class_name InteractController
extends Node

signal interactable_detected(detected: bool, prompt: String)

@export var interact_ray: RayCast3D

var current: Interactable
var is_detecting := false


func _process(_delta: float) -> void:
	var new_target := interact_ray.get_collider() as Interactable if interact_ray.is_colliding() else null
	
	if new_target != current:
		_set_current(new_target)
	
	is_detecting = not not current
	
	if not current: return
	
	# Check if current has the interact key that is being pressed, then call interact with that key.
	if Input.is_action_just_pressed("interact_E") and current.has_key(InteractAction.ActionKey.E):
		current.interact(InteractAction.ActionKey.E)
	elif Input.is_action_just_pressed("interact_F") and current.has_key(InteractAction.ActionKey.F):
		current.interact(InteractAction.ActionKey.F)


func _set_current(new_target: Interactable) -> void:
	if is_instance_valid(current):
		current.focused = false
	current = new_target
	if current:
		current.focused = true
	interactable_detected.emit(current != null, current.get_prompt() if current else "")


func set_disabled(disabled: bool) -> void:
	set_process(not disabled)
	_set_current(null)
	interact_ray.enabled = not disabled

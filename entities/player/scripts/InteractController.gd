class_name InteractController
extends Node

signal interactable_detected(detected: bool, prompt: String)

@export var interact_ray: RayCast3D

var was_colliding := false
var current: InteractableComponent


func _process(_delta: float) -> void:
	var new_target := interact_ray.get_collider() as InteractableComponent if interact_ray.is_colliding() else null

	if new_target != current:
		current = new_target
		interactable_detected.emit(current != null, current.prompt if current else "")
	
	if not current: return
	
	# Check if current has the interact key that is being pressed, then call interact with that key.
	if Input.is_action_just_pressed("interact_E") and InteractableComponent.INTERACT_KEY.E in current.interact_keys:
		current.interact(InteractableComponent.INTERACT_KEY.E)
	elif Input.is_action_just_pressed("interact_F") and InteractableComponent.INTERACT_KEY.F in current.interact_keys:
		current.interact(InteractableComponent.INTERACT_KEY.F)
	

func set_disabled(disabled: bool) -> void:
	set_process(not disabled)
	interact_ray.enabled = not disabled
	if disabled and was_colliding:
		was_colliding = false
		current = null
		interactable_detected.emit(false, "")

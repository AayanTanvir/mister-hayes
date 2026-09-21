class_name InteractController
extends Node

signal interactable_detected(detected: bool)
var was_colliding := false
@export var interact_ray: RayCast3D


func _process(_delta: float) -> void:
	var is_colliding := interact_ray.is_colliding()
	
	if (is_colliding != was_colliding):
		was_colliding = is_colliding
		interactable_detected.emit(is_colliding)
	
	if (is_colliding):
		var interactable := interact_ray.get_collider() as InteractableComponent
		
		if Input.is_action_just_pressed("interact") and interactable:
			interactable.interact()


func set_disabled(disabled: bool):
	set_process(!disabled)
	interact_ray.enabled = !disabled
	interactable_detected.emit(disabled)

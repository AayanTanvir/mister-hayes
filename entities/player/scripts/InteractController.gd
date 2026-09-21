class_name InteractController
extends Node

signal interactable_detected(detected: bool)

@export var interact_ray: RayCast3D

var was_colliding := false


func _process(_delta: float) -> void:
	var is_colliding := interact_ray.is_colliding()

	if is_colliding != was_colliding:
		was_colliding = is_colliding
		interactable_detected.emit(is_colliding)

	if is_colliding and Input.is_action_just_pressed("interact"):
		var interactable := interact_ray.get_collider() as InteractableComponent
		if interactable:
			interactable.interact()


func set_disabled(disabled: bool) -> void:
	set_process(not disabled)
	interact_ray.enabled = not disabled
	if disabled and was_colliding:
		was_colliding = false
		interactable_detected.emit(false)	# hide the crosshair

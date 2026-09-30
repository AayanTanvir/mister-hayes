class_name Player
extends CharacterBody3D

enum State { WALKING, SEATED }

var state := State.WALKING

@export var camera_controller: CameraController
@export var movement_controller: Node3D
@export var interact_controller: InteractController
@export var collision_shape: CollisionShape3D
@export var mesh: MeshInstance3D
@export var camera: Camera3D
@export var inspect_point: Marker3D
@export var inspect_background: TextureRect


func _ready() -> void:
	inspect_background.visible = false


## Put the player in a seat. The seat marker is the eye position: the player is
## parented to it and the head turns around it, limited to seated look angles.
func seat_in(seat: Node3D) -> void:
	state = State.SEATED
	reparent(seat, false)
	transform = Transform3D(Basis.IDENTITY, -camera_controller.position)	# eyes end up on the marker
	camera_controller.enter_seat_mode(seat)
	set_movement_enabled(false)
	collision_shape.set_deferred("disabled", true)
	mesh.visible = false


## Look and interact on/off
func set_look_enabled(enabled: bool, change_camera: bool = true) -> void:
	if change_camera:
		camera_controller.set_disabled(not enabled)
	interact_controller.set_disabled(not enabled)


func set_movement_enabled(enabled: bool):
	movement_controller.set_disabled(not enabled)

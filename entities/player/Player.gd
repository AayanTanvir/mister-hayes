class_name Player
extends CharacterBody3D

enum State { WALKING, SEATED }

var state := State.WALKING

@onready var camera_controller: CameraController = %CameraController
@onready var movement_controller: Node3D = %MovementController
@onready var collision_shape: CollisionShape3D = %PlayerCollisionShape
@onready var mesh: MeshInstance3D = %PlayerMesh
@onready var camera: Camera3D = %PlayerCamera
@export var interact_controller: InteractController
@export var hold_marker: Marker3D

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


func set_look_enabled(enabled: bool, change_camera: bool = true) -> void:
	if change_camera:
		camera_controller.set_disabled(not enabled)
	interact_controller.set_disabled(not enabled)


func set_movement_enabled(enabled: bool):
	movement_controller.set_disabled(not enabled)

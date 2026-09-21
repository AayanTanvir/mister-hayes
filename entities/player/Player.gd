class_name Player
extends CharacterBody3D

enum State { WALKING, SEATED }

var state := State.WALKING

@onready var camera_controller: CameraController = $CameraController
@onready var camera: Camera3D = $CameraController/PlayerCamera
@onready var movement_controller: Node3D = $MovementController
@onready var interact_controller: InteractController = $InteractController
@onready var collision_shape: CollisionShape3D = $PlayerCollisionShape
@onready var mesh: MeshInstance3D = $PlayerMesh


## Put the player in a seat. The seat marker is the eye position: the player is
## parented to it and the head turns around it, limited to seated look angles.
func seat_in(seat: Node3D) -> void:
	state = State.SEATED
	reparent(seat, false)
	transform = Transform3D(Basis.IDENTITY, -camera_controller.position)	# eyes end up on the marker
	camera_controller.enter_seat_mode(seat)
	movement_controller.set_disabled(true)
	collision_shape.set_deferred("disabled", true)
	mesh.visible = false


## Look and interact on/off (cutscenes turn this off).
func set_look_enabled(enabled: bool) -> void:
	camera_controller.set_disabled(not enabled)
	interact_controller.set_disabled(not enabled)

class_name Player
extends CharacterBody3D

enum PlayerState {
	WALKING,
	DRIVING
}

var state := PlayerState.WALKING
@onready var camera_controller: Node3D = $CameraController
@onready var movement_controller: Node3D = $MovementController
@onready var interact_controller: InteractController = $InteractController
@onready var player_collision_shape: CollisionShape3D = $PlayerCollisionShape
@onready var player_mesh: MeshInstance3D = $PlayerMesh


func enter_driving_mode():
	state = PlayerState.DRIVING
	camera_controller.set_disabled(true)
	movement_controller.set_disabled(true)
	interact_controller.set_disabled(true)
	player_collision_shape.disabled = true
	player_mesh.visible = false
	
	
func exit_driving_mode():
	state = PlayerState.WALKING
	camera_controller.set_disabled(false)
	movement_controller.set_disabled(false)
	interact_controller.set_disabled(false)
	player_collision_shape.disabled = false
	player_mesh.visible = true


func _on_car_interacted(entered: bool):
	if entered:
		enter_driving_mode()
	else:
		exit_driving_mode()

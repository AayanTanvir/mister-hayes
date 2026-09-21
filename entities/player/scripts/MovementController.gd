extends Node3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var player: CharacterBody3D


func _ready() -> void:
	player = get_parent() as CharacterBody3D


func _physics_process(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta

	if Input.is_action_just_pressed("space") and player.is_on_floor():
		player.velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = direction.x * SPEED
		player.velocity.z = direction.z * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
		player.velocity.z = move_toward(player.velocity.z, 0, SPEED)

	player.move_and_slide()


func set_disabled(disabled: bool):
	set_physics_process(!disabled)

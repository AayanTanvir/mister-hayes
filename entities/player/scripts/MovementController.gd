class_name MovementController
extends Node3D

const WALK_SPEED := 5.0
const SPRINT_SPEED := 7.0
const HALT_SMOOTHING := 8.0

const BOB_FREQ := 2.4
const WALK_BOB_AMP := 0.04
const SPRINT_BOB_AMP := 0.09
const BOB_SMOOTHING := 12.0


var _is_sprinting := false
var _bob_time := 0.0
@onready var _player: CharacterBody3D = get_parent() as CharacterBody3D
@onready var _camera: Camera3D = get_node("%PlayerCamera")
@onready var _camera_rest: Vector3 = _camera.position if _camera else Vector3.ZERO


func _physics_process(delta: float) -> void:
	if not _player.is_on_floor():
		_player.velocity += _player.get_gravity() * delta
	else:
		_is_sprinting = Input.is_action_pressed("sprint")

	var speed := SPRINT_SPEED if _is_sprinting else WALK_SPEED
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (_player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		_player.velocity.x = direction.x * speed
		_player.velocity.z = direction.z * speed
	else:
		_player.velocity.x = move_toward(_player.velocity.x, 0, speed * HALT_SMOOTHING * delta)
		_player.velocity.z = move_toward(_player.velocity.z, 0, speed * HALT_SMOOTHING * delta)

	_player.move_and_slide()
	_update_bob(delta)


func _update_bob(delta: float) -> void:
	if _camera == null:
		return
	var horizontal_speed := Vector2(_player.velocity.x, _player.velocity.z).length()
	var target := _camera_rest

	if _player.is_on_floor() and horizontal_speed > 0.1:
		_bob_time += delta * horizontal_speed
		var amp := SPRINT_BOB_AMP if _is_sprinting else WALK_BOB_AMP
		target.y += sin(_bob_time * BOB_FREQ) * amp
		target.x += cos(_bob_time * BOB_FREQ * 0.5) * amp

	_camera.position = _camera.position.lerp(target, 1.0 - exp(-BOB_SMOOTHING * delta))

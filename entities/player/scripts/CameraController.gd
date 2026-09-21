class_name CameraController
extends Node3D

const FREE_PITCH_LIMIT := 90.0
const SEAT_PITCH_LIMIT := 75.0
const SEAT_YAW_LIMIT := 105.0

@export var camera_yaw: Node3D	# the node that turns left/right (this node only pitches)
@export_range(0.001, 0.01) var mouse_sensitivity := 0.002

var seated := false
var _mouse_captured := false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_mouse_captured = true


func _process(_delta: float) -> void:
	# runs even while look is disabled, so esc / click still work during cutscenes
	if Input.is_action_just_pressed("esc") and _mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_mouse_captured = false
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not _mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_mouse_captured = true


func _input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return

	var mouse_delta: Vector2 = event.screen_relative
	rotate_x(-mouse_delta.y * mouse_sensitivity)
	camera_yaw.rotate_y(-mouse_delta.x * mouse_sensitivity)

	var pitch_limit := deg_to_rad(SEAT_PITCH_LIMIT if seated else FREE_PITCH_LIMIT)
	rotation.x = clampf(rotation.x, -pitch_limit, pitch_limit)

	if seated:
		var yaw_limit := deg_to_rad(SEAT_YAW_LIMIT)
		camera_yaw.rotation.y = clampf(camera_yaw.rotation.y, -yaw_limit, yaw_limit)


## Limit looking to what a seated person can do. `yaw_pivot` should sit at eye
## position so the head turns in place instead of orbiting.
func enter_seat_mode(yaw_pivot: Node3D) -> void:
	camera_yaw = yaw_pivot
	seated = true
	rotation = Vector3.ZERO


func set_disabled(disable: bool) -> void:
	set_process_input(not disable)

class_name CarRoute
extends PathFollow3D

signal finished

@export var cruise_speed := 12.0
@export var acceleration := 2.0
@export var corner_slowdown := 0.6

var speed := 0.0
var curvature := 0.0
var _prev_yaw := 0.0
var _running := false
var _done := false


func _ready() -> void:
	loop = false
	rotation_mode = ROTATION_Y


func start() -> void:
	_prev_yaw = global_rotation.y
	_running = true


func wait_until_ratio(ratio: float) -> void:
	while progress_ratio < ratio:
		await get_tree().physics_frame


func _physics_process(delta: float) -> void:
	if not _running or _done:
		return

	var path_length := (get_parent() as Path3D).curve.get_baked_length()
	var remaining := path_length - progress

	var bend := clampf(absf(curvature) / 0.05, 0.0, 1.0)
	var target := cruise_speed * lerpf(1.0, corner_slowdown, bend)
	target = minf(target, maxf(remaining * 0.6, 0.8))

	speed = move_toward(speed, target, acceleration * delta)
	progress += speed * delta

	var yaw := global_rotation.y
	var dyaw := wrapf(yaw - _prev_yaw, -PI, PI)
	_prev_yaw = yaw
	var dist := speed * delta
	if dist > 0.001:
		curvature = lerpf(curvature, dyaw / dist, 1.0 - exp(-6.0 * delta))

	if remaining < 0.1:
		_done = true
		speed = 0.0
		finished.emit()

class_name CarRoute
extends PathFollow3D

signal finished

const CURVATURE_SPAN := 2.0

@export var cruise_speed := 12.0
@export var acceleration := 2.0
@export var corner_slowdown := 0.6
@export var look_ahead := 3.0

var speed := 0.0
var curvature := 0.0

var _running := false
var _done := false

@onready var _curve: Curve3D = (get_parent() as Path3D).curve


func _ready() -> void:
	loop = false
	rotation_mode = ROTATION_Y


func start() -> void:
	_running = true


func wait_until_ratio(ratio: float) -> void:
	while progress_ratio < ratio:
		await get_tree().process_frame


func _process(delta: float) -> void:
	if not _running or _done:
		return

	var remaining := _curve.get_baked_length() - progress
	curvature = _road_curvature(progress + look_ahead)

	var bend := clampf(absf(curvature) / 0.05, 0.0, 1.0)
	var target := cruise_speed * lerpf(1.0, corner_slowdown, bend)
	target = minf(target, maxf(remaining * 0.6, 0.8))

	speed = move_toward(speed, target, acceleration * delta)
	progress += speed * delta

	if remaining < 0.1:
		_done = true
		speed = 0.0
		finished.emit()


func _road_curvature(offset: float) -> float:
	var a := _point_at(offset)
	var b := _point_at(offset + CURVATURE_SPAN)
	var c := _point_at(offset + CURVATURE_SPAN * 2.0)
	var d1 := b - a
	var d2 := c - b
	if d1.length_squared() < 0.0001 or d2.length_squared() < 0.0001:
		return 0.0

	var yaw1 := atan2(-d1.x, -d1.z)
	var yaw2 := atan2(-d2.x, -d2.z)
	return wrapf(yaw2 - yaw1, -PI, PI) / CURVATURE_SPAN


func _point_at(offset: float) -> Vector3:
	var length := _curve.get_baked_length()
	offset = fposmod(offset, length) if _curve.closed else clampf(offset, 0.0, length)
	return _curve.sample_baked(offset)

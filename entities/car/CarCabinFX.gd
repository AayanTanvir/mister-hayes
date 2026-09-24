class_name CarCabinFX
extends Node3D

@export var sway: Node3D			# body, cabin and seat. the part that leans and bobs
@export var seat: Marker3D
@export var steering_wheel: Node3D
@export var wheel_fl: Node3D
@export var wheel_fr: Node3D
@export var wheel_bl: Node3D
@export var wheel_br: Node3D

@export_group("Steering")
@export var wheelbase := 3.6
@export var steering_ratio := 8.0	## Ratio of steering wheel to wheels rotation
@export var steering_smoothing := 6.0

@export_group("Wheels")
@export_range(10, 45) var max_road_wheel_angle := 40.0
@export var wheel_radius := 0.9
@export var wheel_spin_smoothing := 10.0

@export_group("Body motion")
@export var roll_amount := 0.004
@export var pitch_amount := 0.006
@export var bump_amount := 0.003
@export var motion_smoothing := 4.0

var _steer := 0.0
var _accel := 0.0
var _prev_speed := 0.0
var _wheel_rest: Basis
var _fl_rest: Basis
var _fr_rest: Basis
var _bl_rest: Basis
var _br_rest: Basis
var _wheel_spin := 0.0

@onready var route := get_parent() as CarRoute


func _ready() -> void:
	# rotate relative to these
	_wheel_rest = steering_wheel.basis
	_fl_rest = wheel_fl.basis
	_fr_rest = wheel_fr.basis
	_bl_rest = wheel_bl.basis
	_br_rest = wheel_br.basis


func _process(delta: float) -> void:
	if route == null or delta <= 0.0:
		return

	var target := clampf(
		atan(wheelbase * route.curvature),
		deg_to_rad(-max_road_wheel_angle),
		deg_to_rad(max_road_wheel_angle)
	)
	
	_steer = lerpf(_steer, target, 1.0 - exp(-steering_smoothing * delta))

	steering_wheel.basis = _wheel_rest * Basis(Vector3.BACK, -(_steer * steering_ratio))
	
	# Spin and rotate wheels
	_wheel_spin += (route.speed / wheel_radius) * delta
	wheel_fl.basis = (
		_fl_rest
		* Basis(Vector3.UP, _steer)
		* Basis(Vector3.RIGHT, _wheel_spin)
	)
	wheel_fr.basis = (
		_fr_rest
		* Basis(Vector3.UP, _steer)
		* Basis(Vector3.RIGHT, _wheel_spin)
	)
	wheel_bl.basis = (_bl_rest * Basis(Vector3.RIGHT, _wheel_spin))
	wheel_br.basis = (_br_rest * Basis(Vector3.RIGHT, _wheel_spin))


	# Body motion
	var k := 1.0 - exp(-motion_smoothing * delta)
	_accel = lerpf(_accel, (route.speed - _prev_speed) / delta, k)
	_prev_speed = route.speed

	var lateral := route.speed * route.speed * route.curvature
	sway.rotation.z = lerpf(sway.rotation.z, clampf(-lateral * roll_amount, -0.06, 0.06), k)	# lean out of the bend
	sway.rotation.x = lerpf(sway.rotation.x, clampf(_accel * pitch_amount, -0.04, 0.04), k)	# nose up when accelerating

	var speed_ratio := clampf(route.speed / maxf(route.cruise_speed, 0.1), 0.0, 1.0)
	var t := Time.get_ticks_msec() / 1000.0
	sway.position.y = (sin(t * 7.3) * 0.6 + sin(t * 13.1) * 0.4) * bump_amount * speed_ratio

class_name CarCabinFX
extends Node3D
## Visual life for the self-driving car: steering wheel, front wheels, body lean and road bumps.
## Reads everything from the CarRoute it's parented under. No physics involved.

@export var sway: Node3D			# body, cabin and seat; the part that leans and bobs
@export var seat: Marker3D			# the player's eye position
@export var steering_wheel: Node3D
@export var wheel_fl: Node3D
@export var wheel_fr: Node3D

@export_group("Steering")
@export var wheelbase := 3.6
@export var steering_ratio := 13.0
@export_range(0.1, 0.8) var max_road_wheel_angle := 0.6	# radians
@export var steering_smoothing := 6.0

@export_group("Body motion")
@export var roll_amount := 0.004
@export var pitch_amount := 0.006
@export var bump_amount := 0.012
@export var motion_smoothing := 4.0

var _steer := 0.0
var _accel := 0.0
var _prev_speed := 0.0
var _wheel_rest: Basis
var _fl_rest: Basis
var _fr_rest: Basis

@onready var route := get_parent() as CarRoute


func _ready() -> void:
	# remember the authored orientations; we rotate relative to these
	_wheel_rest = steering_wheel.basis
	_fl_rest = wheel_fl.basis
	_fr_rest = wheel_fr.basis


func _process(delta: float) -> void:
	if route == null or delta <= 0.0:
		return

	# Steering: bicycle model gives the road-wheel angle for the bend ahead
	var target := clampf(atan(wheelbase * route.curvature), -max_road_wheel_angle, max_road_wheel_angle)
	_steer = lerpf(_steer, target, 1.0 - exp(-steering_smoothing * delta))

	# The steering wheel's spin axis is its local Y (it's tilted), so rotate in local space
	steering_wheel.basis = _wheel_rest * Basis(Vector3.UP, _steer * steering_ratio)
	wheel_fl.basis = _fl_rest * Basis(Vector3.UP, _steer)
	wheel_fr.basis = _fr_rest * Basis(Vector3.UP, _steer)

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

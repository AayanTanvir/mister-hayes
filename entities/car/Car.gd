extends InteractableComponent

@export var car_camera: Camera3D
@export var camera_controller: Node3D
@export var exit_point: Marker3D
@export var interact_controller: InteractController
@export var car: VehicleBody3D

var root: Prototype
var driving := false

const MAX_STEER := 0.7
const STEER_SPEED := 4.0

const MAX_SPEED := 40.0
const MAX_REVERSE_SPEED := 6.0

const INITIAL_ENGINE_FORCE := 4000.0
const MAX_ENGINE_FORCE := 10000.0
const INITIAL_ACCELERATION_SPEED := 12.0

const MAX_BRAKE_FORCE := 18.0
const MIN_BRAKE_FORCE := 6.0
const BRAKE_APPLICATION_SPEED := 12.0


func _ready() -> void:
	root = get_tree().current_scene
	interact_controller.set_disabled(true)
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if not driving:
		return

	var steer_input := Input.get_axis("right", "left")

	car.steering = move_toward(
		car.steering,
		steer_input * MAX_STEER,
		STEER_SPEED * delta
	)

	var move_input := Input.get_axis("backward", "forward")
	var speed := _get_forward_speed()

	if move_input > 0.0:
		_accelerate(speed)

	elif move_input < 0.0:
		_reverse_or_brake(delta, speed)

	else:
		_coast()


func _accelerate(speed: float) -> void:
	car.brake = 0.0

	if speed >= MAX_SPEED:
		car.engine_force = 0.0
		return

	var acceleration_ratio := clampf(
		speed / INITIAL_ACCELERATION_SPEED,
		0.0,
		1.0
	)

	var target_force := lerpf(
		INITIAL_ENGINE_FORCE,
		MAX_ENGINE_FORCE,
		acceleration_ratio
	)

	if speed > INITIAL_ACCELERATION_SPEED:
		var top_speed_ratio := clampf(
			(speed - INITIAL_ACCELERATION_SPEED)
			/ (MAX_SPEED - INITIAL_ACCELERATION_SPEED),
			0.0,
			1.0
		)

		target_force = lerpf(
			MAX_ENGINE_FORCE,
			0.0,
			top_speed_ratio
		)

	car.engine_force = target_force


func _reverse_or_brake(delta: float, speed: float) -> void:
	car.engine_force = 0.0

	if speed > 0.5:
		var speed_ratio := clampf(
			speed / MAX_SPEED,
			0.0,
			1.0
		)

		var target_brake := lerpf(
			MAX_BRAKE_FORCE,
			MIN_BRAKE_FORCE,
			speed_ratio
		)

		car.brake = move_toward(
			car.brake,
			target_brake,
			BRAKE_APPLICATION_SPEED * delta
		)

	else:
		car.brake = 0.0

		if speed > -MAX_REVERSE_SPEED:
			car.engine_force = -INITIAL_ENGINE_FORCE
		else:
			car.engine_force = 0.0


func _coast() -> void:
	car.engine_force = 0.0
	car.brake = 0.0


func interact() -> void:
	if not driving:
		root.set_car_interacted(true)
		driving = true
		start_driving()
	else:
		root.set_car_interacted(false)
		driving = false
		end_driving()


func start_driving() -> void:
	car_camera.current = true
	camera_controller.set_disabled(false)
	interact_controller.set_disabled(false)
	set_physics_process(true)


func end_driving() -> void:
	car_camera.current = false
	camera_controller.set_disabled(true)
	interact_controller.set_disabled(true)
	set_physics_process(false)

	car.engine_force = 0.0
	car.brake = 0.0


func _get_forward_speed() -> float:
	var forward := -car.global_transform.basis.z
	return car.linear_velocity.dot(forward)

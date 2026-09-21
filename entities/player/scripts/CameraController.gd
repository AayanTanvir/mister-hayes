extends Node3D

@export var camera_yaw: Node3D
@export_range(0.001, 0.01) var mouse_sensitivity := 0.002
@export var is_car_camera := false
var isMouseCaptured := false
const CAR_CAMERA_Y_CLAMP := 105.0
const CAR_CAMERA_X_CLAMP := 75.0
const CAMERA_X_CLAMP := 90.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	isMouseCaptured = true
	
	# disable car camera at start
	if is_car_camera:
		set_disabled(true)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc") and isMouseCaptured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		isMouseCaptured = false
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not isMouseCaptured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		isMouseCaptured = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_delta: Vector2 = event.screen_relative
		rotate_x(-mouse_delta.y * mouse_sensitivity)
		camera_yaw.rotate_y(-mouse_delta.x * mouse_sensitivity)
		
		rotation.x = clampf(
			rotation.x,
			deg_to_rad(-CAMERA_X_CLAMP if not is_car_camera else -CAR_CAMERA_X_CLAMP),
			deg_to_rad(CAMERA_X_CLAMP if not is_car_camera else CAR_CAMERA_X_CLAMP)
		)
		
		if is_car_camera:
			camera_yaw.rotation.y = clampf(
				camera_yaw.rotation.y,
				deg_to_rad(-105.0),
				deg_to_rad(105.0)
			)


func set_disabled(disable: bool):
	set_process_input(!disable)
	set_process(!disable)

class_name Intro
extends Node3D

@export var route: CarRoute
@export var car: CarCabinFX
@export var player: Player
@export var ui: UI
@export var chase_cam: Camera3D

@export var chase_duration := 8.0
@export_range(0.0, 1.0) var handoff_ratio := 0.85	## route progress where the interior phase ends


func _ready() -> void:
	player.interact_controller.interactable_detected.connect(ui._on_interactable_detected)
	player.seat_in(car.seat)
	player.set_look_enabled(false)

	# 1. exterior cutscene
	chase_cam.make_current()
	route.start()
	await get_tree().create_timer(chase_duration).timeout

	# 2. inside the car, player looks around and interacts with props
	player.camera.make_current()
	player.set_look_enabled(true)
	await route.wait_until_ratio(handoff_ratio)

	# 3. drone shot of the village, then title card
	player.set_look_enabled(false)
	# TODO: drone_cam.make_current(), await route.finished, show title card

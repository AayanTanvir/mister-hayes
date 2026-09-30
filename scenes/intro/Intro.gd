class_name Intro
extends Node3D

@export var car_route: CarRoute
@export var drone_route: DroneCamRoute
@export var car: CarCabinFX
@export var chase_cam: Camera3D
@export var drone_cam: Camera3D
@export var chase_duration := 10.0
@export_range(0.0, 1.0) var handoff_ratio := 0.85	## route progress where the interior phase ends

var player: Player
var ui: UI

var intro_dialogue: Array[Dictionary] = [
	{
		"speaker": "Ethan",
		"text": "Why did they do this to me?"
	},
	{
		"speaker": "Ethan",
		"text": "I'm so done with this..."
	},
]


func _ready() -> void:
	player = GameManager.player
	ui = GameManager.ui
	
	start_intro()


func start_intro():
	player.seat_in(car.seat)
	player.set_look_enabled(false)
	ui.set_hud_visible(false)

	# 1. exterior cutscene
	chase_cam.make_current()
	car_route.start()
	await get_tree().create_timer(chase_duration).timeout

	# 2. inside the car, player looks around and interacts with props
	player.camera.make_current()
	player.set_look_enabled(true)
	ui.set_hud_visible(true)
	await get_tree().create_timer(3.0).timeout
	DialogueManager.start_dialogue(intro_dialogue, false)
	await car_route.wait_until_ratio(handoff_ratio)

	# 3. drone shot of the map, then title card
	player.set_look_enabled(false)
	ui.set_hud_visible(false)
	drone_cam.make_current()
	drone_route.start()

class_name Intro
extends Node

@export var car_route: CarRoute
@export var drone_route: DroneCamRoute
@export var car: CarCabinFX
@export_range(0.0, 1.0) var handoff_ratio := 0.85	## route progress where the interior phase ends
@export_range(0.0, 1.0) var ethan_dialogue_ratio := 0.7	## route progress where ethan says dialogue

@export_group("Shots")
@export var chase_cam: Camera3D
@export var drone_cam: Camera3D
@export var pass_by_cam: Camera3D
@export var chase_duration := 5.0
@export var pass_by_duration := 3.0


var player: Player
var ui: UI

var intro_dialogue: Array[Dictionary] = [
	{
		"speaker": "Ethan",
		"text": "Middle of nowhere... 'course they did."
	},
	{
		"speaker": "Ethan",
		"text": "Guess there's nothing left in the city for me anyway."
	},
]


func _ready() -> void:
	player = GameManager.player
	ui = GameManager.ui
	
	start_intro()


func start_intro():
	player.seat_in(car.seat)
	player.disable_look(true)
	ui.set_hud_visible(false)

	# chase
	chase_cam.make_current()
	car_route.start()
	await get_tree().create_timer(chase_duration).timeout

	# pass by shot
	pass_by_cam.make_current()
	await get_tree().create_timer(pass_by_duration).timeout

	# inside the car
	player.camera.make_current()
	player.disable_look(false)
	ui.set_hud_visible(true)
	await car_route.wait_until_ratio(ethan_dialogue_ratio)
	DialogueManager.start_dialogue(intro_dialogue, false)
	await car_route.wait_until_ratio(handoff_ratio)

	# drone shot of the map, then title card
	player.disable_look(true)
	ui.set_hud_visible(false)
	drone_cam.make_current()
	drone_route.start()

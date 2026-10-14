class_name IntroDrive
extends Node

@export_range(0.0, 1.0) var handoff_ratio := 0.655 	## route progress where the interior phase ends
@export_range(0.0, 1.0) var ethan_dialogue_ratio := 0.1	## route progress where ethan says dialogue

@export_group("References")
@export var car_route: CarRoute
@export var car: CarCabinFX
@export var track_player: AudioStreamPlayer
@export var black_screen: ColorRect
@export var engine_audio: EngineAudio

@export_group("Shots")
@export var chase_cam: Camera3D
@export var drone_cam: Camera3D
@export var pass_by_cam: Camera3D
@export var chase_duration := 5.0
@export var pass_by_duration := 3.0
@export var drone_shot_anim_player: AnimationPlayer


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
	
	black_screen.hide()
	start_intro()


func start_intro():
	player.seat_in(car.seat)
	player.disable_cam(true)
	player.disable_interact(true)
	ui.hud_visible(false)
	
	# chase
	chase_cam.make_current()
	car_route.start()
	
	track_player.play()
	engine_audio.play()
	engine_audio.set_inside(false)
	
	await get_tree().create_timer(chase_duration).timeout

	# pass by shot
	pass_by_cam.make_current()
	await get_tree().create_timer(pass_by_duration).timeout
	
	# inside the car
	player.camera.make_current()
	player.disable_cam(false)
	ui.hud_visible(true)
	engine_audio.set_inside(true)
	
	await get_tree().create_timer(1.0).timeout
	ScriptManager.start_single_dialogue(intro_dialogue, true)
	await ScriptManager.idle
	player.disable_interact(false)	# Allow interaction after dialogue
	
	await car_route.wait_until_ratio(handoff_ratio)

	# drone shot, then title card
	player.disable_cam(true)
	player.disable_interact(true)
	ui.hud_visible(false)
	GameManager.restrict_changes(true)
	
	drone_cam.make_current()
	await get_tree().process_frame
	
	engine_audio.set_inside(false)
	drone_shot_anim_player.play("drone_pullback")
	await drone_shot_anim_player.animation_finished
	engine_audio.stop()
	black_screen.show()
	GameManager.restrict_changes(false)
	await get_tree().create_timer(4.0).timeout
	
	GameState.set_state("intro_drive_sequence_completed", true)
	SceneManager.change_scene(SceneManager.Scenes.TOWN)

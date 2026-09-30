extends Node

var ui: UI
var player: Player

var mouse_captured := false


func _ready() -> void:
	set_mouse_visible(false)
	
	ui = get_tree().current_scene.get_node("%UI") as UI
	player = get_tree().current_scene.get_node("%Player") as Player
	if not ui or not player:
		push_error("Required nodes not found")
		return
	
	_assign_signals()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc") and mouse_captured:
		set_mouse_visible(true)


func _assign_signals():
	player.interact_controller.interactable_detected.connect(ui._on_interactable_detected)


func update_interact_prompt(new_prompt: String):
	ui.set_interact_prompt(new_prompt)


func set_inspection_mode(inspect: bool):
	if player.state != player.State.SEATED:
		player.set_movement_enabled(not inspect)
	player.set_look_enabled(not inspect)
	ui.set_hud_visible(not inspect)


func set_mouse_visible(show: bool):
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if show else Input.MOUSE_MODE_CAPTURED
	mouse_captured = not show

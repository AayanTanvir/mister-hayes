extends Node

var ui: UI
var player: Player

var mouse_captured := false
var _changes_restricted := false


func _ready() -> void:
	set_mouse_visible(false)
	
	ui = get_tree().current_scene.get_node("%UI") as UI
	player = get_tree().current_scene.get_node("%Player") as Player
	if not ui or not player:
		push_error("Required nodes not found")
		return
	
	_assign_signals()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("grave") and mouse_captured:
		set_mouse_visible(true)


func _assign_signals():
	player.interact_controller.interactable_detected.connect(ui._on_interactable_detected)


## Hides HUD and disables player cam/interact/movement.[br]
## set global = true to disable other interactions to changing the mode
func interact_mode(enable: bool):
	if _changes_restricted:
		return
	
	player.disable_cam(enable)
	player.disable_interact(enable)
	if not player.state == player.State.SEATED:
		player.set_movement_enabled(not enable)
	ui.hud_visible(not enable) # Changes interact


func paused_interact_mode(enable: bool):
	if _changes_restricted:
		return
	
	pause_game(enable)
	ui.hud_visible(not enable) # Changes interact


## Hides HUD and disables only player interact/movement.
func dialogue_mode(enable: bool):
	if _changes_restricted:
		return
	
	player.disable_interact(enable)
	if not player.state == player.State.SEATED:
		player.set_movement_enabled(not enable)
	ui.hud_visible(not enable) # Changes interact


func pause_game(pause: bool):
	if _changes_restricted:
		return
	
	get_tree().paused = pause


func set_mouse_visible(show: bool):
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if show else Input.MOUSE_MODE_CAPTURED
	mouse_captured = not show


func sync_interact_prompt():
	if _changes_restricted:
		return
	
	if ui.interact_prompt_container.visible != player.interact_controller.is_detecting:
		ui.interact_prompt_container.visible = player.interact_controller.is_detecting


func restrict_changes(restrict: bool):
	_changes_restricted = restrict

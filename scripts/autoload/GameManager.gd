extends Node

var ui: UI
var player: Player

var mouse_captured := false
var _changes_restricted := false


func _ready() -> void:
	set_mouse_visible(false)
	_bind_scene_nodes()	
	get_tree().scene_changed.connect(_bind_scene_nodes)
	


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("grave") and mouse_captured:
		set_mouse_visible(true)


func _bind_scene_nodes() -> void:
	ui = null
	player = null

	var scene := get_tree().current_scene
	if scene == null:
		printerr("scene is null. returning early without binding nodes")
		return

	ui = scene.get_node_or_null("%UI") as UI
	player = scene.get_node_or_null("%Player") as Player
	if not ui or not player:
		return  # TODO: fallback to main menu or something

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

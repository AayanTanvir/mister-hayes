extends Node

signal input_detected

var ui: UI
var player: Player

var showing_dialogue := false


func _ready() -> void:
	ui = get_tree().current_scene.get_node("%UI") as UI
	player = get_tree().current_scene.get_node("%Player") as Player
	if not ui or not player:
		push_error("Required nodes not found")
		return
	
	_stop_dialogue()


func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("interact_E") and showing_dialogue):
		input_detected.emit()


func start_dialogue(dialogue: Array[Dictionary], disable_camera: bool = false):
	if not _validate_dialogue(dialogue):
		push_error("Invalid dialogue input")
		return
	
	ui.dialogue_container.visible = true
	
	# Stop interaction and hide hud
	player.set_look_enabled(false, disable_camera)
	ui.set_hud_visible(false)
	
	showing_dialogue = true
	
	for line in dialogue:
		_show_line(line.speaker, line.text)
		await input_detected
		
	_stop_dialogue()
	player.set_look_enabled(true, disable_camera)
	ui.set_hud_visible(true)


func _show_line(speaker: String, text: String):
	ui.speaker_label.text = speaker
	ui.dialogue_label.text = text


func _stop_dialogue():
	ui.speaker_label.text = ""
	ui.dialogue_label.text = ""
	ui.dialogue_container.visible = false
	showing_dialogue = false


func _validate_dialogue(dialogue: Array[Dictionary]):
	for line in dialogue:
		if not line.has("speaker") or not line.has("text"):
			return false
	return true 

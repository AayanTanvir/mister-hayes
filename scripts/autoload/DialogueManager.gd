extends Node

signal input_detected

var ui: UI
var player: Player

var showing_dialogue := false
var _action_regex := RegEx.new()
var _action_text_color := "#a0a0a0"

var _chars_per_second := 30.0
var _type_tween: Tween
var _typing := false


func _ready() -> void:
	ui = get_tree().current_scene.get_node("%UI") as UI
	player = get_tree().current_scene.get_node("%Player") as Player
	if not ui or not player:
		push_error("Required nodes not found")
		return
	
	_action_regex.compile(r"\*(.+?)\*")
	
	_stop_dialogue()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact_E") and showing_dialogue:
			if _typing:
				_finish_typing()
			else:
				input_detected.emit()


## Display a series of multiple lines, with or without different speakers
func start_dialogue(dialogue: Array[Dictionary], disable_camera: bool = false):
	if not _validate_dialogues(dialogue):
		push_error("Invalid dialogue input")
		return
	
	ui.dialogue_container.visible = true
	
	player.set_look_enabled(false, disable_camera)
	ui.set_hud_visible(false)
	
	showing_dialogue = true
	
	for line in dialogue:
		_show_line(line.speaker, line.text)
		await input_detected
		
	_stop_dialogue()
	player.set_look_enabled(true, disable_camera)
	ui.set_hud_visible(true)


## Show a single line by a single speaker with a defined duration.
func say(dialogue: Dictionary, duration: float = 2.0, disable_camera: bool = false):
	if not _validate_dialogue(dialogue):
		push_error("Invalid dialogue input")
		return
	
	ui.dialogue_container.visible = true
	
	player.set_look_enabled(false, disable_camera)
	ui.set_hud_visible(false)
	
	showing_dialogue = true
	
	_show_line(dialogue.speaker, dialogue.text)
	await _type_tween.finished
	await get_tree().create_timer(duration).timeout
		
	_stop_dialogue()
	player.set_look_enabled(true, disable_camera)
	ui.set_hud_visible(true)


func _show_line(speaker: String, text: String) -> void:
	ui.speaker_label.text = speaker

	var label: RichTextLabel = ui.dialogue_label
	label.text = format_text(text)
	label.visible_ratio = 0.0

	if _type_tween:
		_type_tween.kill()

	var duration := label.get_total_character_count() / _chars_per_second
	_typing = true
	_type_tween = create_tween()
	_type_tween.tween_property(label, "visible_ratio", 1.0, duration)
	_type_tween.finished.connect(func(): _typing = false)


func _stop_dialogue():
	ui.speaker_label.text = ""
	ui.dialogue_label.text = ""
	ui.dialogue_container.visible = false
	showing_dialogue = false


func _validate_dialogue(dialogue: Dictionary):
	if not dialogue.has("speaker") or not dialogue.has("text"):
		return false
	return true


func _validate_dialogues(dialogue: Array[Dictionary]):
	for line in dialogue:
		if not line.has("speaker") or not line.has("text"):
			return false
	return true


func format_text(raw: String) -> String:
	raw = raw.replace("[", "[lb]")
	return _action_regex.sub(raw, "[i][font_size=13][color=%s]$1[/color][/font_size][/i]" % _action_text_color, true)


func _finish_typing() -> void:
	if _type_tween:
		_type_tween.kill()
	ui.dialogue_label.visible_ratio = 1.0
	_typing = false

extends Node

signal input_detected
signal typing_done
signal idle

var ui: UI
var player: Player

var showing_dialogue := false
var _action_regex := RegEx.new()

var _chars_per_second := 30.0
var _type_tween: Tween
var _typing := false
var _advance_id := 0
var auto_advance_time := 10.0 


func _ready() -> void:
	ui = get_tree().current_scene.get_node("%UI") as UI
	player = get_tree().current_scene.get_node("%Player") as Player
	if not ui or not player:
		push_error("Required nodes not found")
		return
	
	_action_regex.compile(r"\*(.+?)\*")
	_set_dialogue_visible(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact_E") and showing_dialogue:
			if _typing:
				_skip_typing()
			else:
				_advance_id += 1
				input_detected.emit()


func sync_dialogue_visiblity():
	if showing_dialogue != ui.dialogue_container.visible:
		ui.dialogue_container.visible = showing_dialogue


## Display a series of multiple lines spokeb by a single person
func start_single_dialogue(dialogue: Array[Dictionary], auto_advance: bool = false):
	_focus(true)
	_set_dialogue_visible(true)
	
	for line in dialogue:
		_show_line(line.text)
		if auto_advance:
			_start_auto_advance()
		await input_detected
	
	_focus(false)
	_set_dialogue_visible(false)
	
	idle.emit()


## Show a single line by a single speaker with a defined duration.
func say(dialogue: Dictionary, duration: float = 1.5):
	_set_dialogue_visible(true)
	
	_show_line(dialogue.text)
	await typing_done
	await get_tree().create_timer(duration).timeout
	
	_set_dialogue_visible(false)
	idle.emit()


func _show_line(text: String) -> void:
	var label: RichTextLabel = ui.dialogue_label
	label.text = format_text(text)
	label.visible_ratio = 0.0

	if _type_tween:
		_type_tween.kill()

	var duration := label.get_total_character_count() / _chars_per_second
	_typing = true
	_type_tween = create_tween()
	_type_tween.tween_property(label, "visible_ratio", 1.0, duration)
	_type_tween.finished.connect(_end_typing)


func _set_dialogue_visible(show: bool):
	showing_dialogue = show
	sync_dialogue_visiblity()


func _focus(show: bool):
	player.disable_interact(show)
	ui.hud_visible(not show)


func format_text(raw: String) -> String:
	raw = raw.replace("[", "[lb]")
	return _action_regex.sub(raw, "[i][font_size=16][color=#ffffff90]$1[/color][/font_size][/i]", true)


func _skip_typing() -> void:
	if _type_tween:
		_type_tween.kill()
	ui.dialogue_label.visible_ratio = 1.0
	_end_typing()


func _end_typing() -> void:
	_typing = false
	typing_done.emit()


func _start_auto_advance() -> void:
	_advance_id += 1
	var id := _advance_id
	await typing_done
	if id != _advance_id:
		return
	await get_tree().create_timer(auto_advance_time).timeout
	if id == _advance_id:
		input_detected.emit()

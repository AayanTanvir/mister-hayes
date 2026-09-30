extends InteractableComponent

@export var audio_player: AudioStreamPlayer

var track_1: AudioStreamMP3 = preload("res://assets/sounds/radio/1.mp3")
var track_2: AudioStreamMP3 = preload("res://assets/sounds/radio/2.mp3")

var _current_track_idx := 0	# 0 = Stopped
var _interact_e_prompt = "[E] Change"
var _interact_f_prompt = "[F] Play"

const TRACKS_COUNT = 2


func _ready() -> void:
	_interact_f_prompt = "[F] Stop" if audio_player.playing else "[F] Play"
	prompt = _interact_e_prompt + "\n" + _interact_f_prompt


func interact(interact_key: InteractableComponent.INTERACT_KEY):
	if interact_key == InteractableComponent.INTERACT_KEY.E:
		var next_track_idx = get_next_idx()
		play_audio(next_track_idx)
	
	elif interact_key == InteractableComponent.INTERACT_KEY.F:
		if audio_player.playing:
			audio_player.stop()
		else:
			play_audio()

	_interact_f_prompt = "[F] Stop" if audio_player.playing else "[F] Play"
	change_interact_prompt(_interact_e_prompt + "\n" + _interact_f_prompt)


func play_audio(tract_idx: int = 1):
	match tract_idx:
		1:
			audio_player.stream = track_1
			_current_track_idx = 1
		2:
			audio_player.stream = track_2
			_current_track_idx = 2
		_:
			return
	
	audio_player.play()
	

func get_next_idx():
	if _current_track_idx >= TRACKS_COUNT:
		return 1
	return _current_track_idx + 1

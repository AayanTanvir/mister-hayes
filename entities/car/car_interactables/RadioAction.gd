class_name RadioAction
extends InteractAction

@export var audio_player: AudioStreamPlayer
@export var tracks: Array[AudioStream]

var _track_idx := -1  # -1 = nothing played yet


func _ready() -> void:
	audio_player.finished.connect(prompt_changed.emit)


func handles(k: ActionKey) -> bool:
	if audio_player.playing:
		return k == ActionKey.E or k == ActionKey.F
	else:
		return k == ActionKey.E


func get_prompt() -> String:
	return  ("[E] Stop\n[F] Change" if audio_player.playing else "[E] Play")


func execute(k: ActionKey) -> void:
	match k:
		ActionKey.E:
			if audio_player.playing:
				audio_player.stop()
			else:
				_play(maxi(_track_idx, 0))
		ActionKey.F:
			_play((_track_idx + 1) % tracks.size())
	
	prompt_changed.emit()


func _play(idx: int) -> void:
	_track_idx = idx
	audio_player.stream = tracks[idx]
	audio_player.play()

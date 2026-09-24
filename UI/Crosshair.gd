extends Control

@export var _crosshair: TextureRect
@export var _interact_crosshair: TextureRect
@export_range(0.1, 1.5, 0.1) var fade_duration = 1.0
var interact_crosshair_tween: Tween


func _ready() -> void:
	set_crosshair_visible(true)
	_interact_crosshair.modulate.a = 0.0


func show_interact_crosshair(show_crosshair: bool):
	if interact_crosshair_tween: interact_crosshair_tween.kill()
	
	if show_crosshair:
		interact_crosshair_tween = create_tween()
		interact_crosshair_tween.tween_property(_interact_crosshair, "modulate:a", 1.0, fade_duration)
	else:
		_interact_crosshair.modulate.a = 0.0


func set_crosshair_visible(set_visible: bool):
	_crosshair.visible = set_visible
	_interact_crosshair.visible = set_visible

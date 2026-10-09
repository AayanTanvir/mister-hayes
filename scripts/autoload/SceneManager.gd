extends Node

enum Scenes { INTRO_DRIVING, TOWN }

const PATHS := {
	Scenes.INTRO_DRIVING: "res://scenes/intro_drive/IntroDrive.tscn",
	Scenes.TOWN: "res://scenes/town/Town.tscn",
}

var _overlay: ColorRect
var _fade_tween: Tween
var _changing := false


func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 128
	add_child(layer)

	_overlay = ColorRect.new()
	_overlay.color = Color.BLACK
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.modulate.a = 0.0
	layer.add_child(_overlay)


func change_scene(to: Scenes, fade_out_time := 2.0) -> void:
	if _changing:
		return
	_changing = true

	_overlay.modulate.a = 1.0
	get_tree().change_scene_to_file(PATHS[to])

	# let the new scene render a few frames
	for i in 3:
		await get_tree().process_frame

	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_overlay, "modulate:a", 0.0, fade_out_time).set_ease(Tween.EASE_OUT)
	await _fade_tween.finished
	_changing = false

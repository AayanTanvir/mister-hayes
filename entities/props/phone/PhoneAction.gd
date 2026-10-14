class_name PhoneAction
extends InteractAction

const MOVE_TIME := 0.4
const FADE_TIME := 0.2


@export var _screen_viewport: SubViewport
@export var _phone_ui: Control
@export var _phone_root: Node3D
@export_range(1.0, 10.0, 0.5) var hold_duration := 1.5

var _home: Node3D
var _rest_local: Transform3D
var _busy := false
var _has_used := false

var _post_use_lines = [
	"Still nothing.",
	"Real popular guy.",
	"Eyes on the road.",
	"Stop checking, Hayes.",
	"Nope.",
]
var _line_idx := 0


func _ready() -> void:
	_home = _phone_root.get_parent_node_3d()
	_rest_local = _phone_root.transform
	GameManager.ui.phone_overlay.texture = _screen_viewport.get_texture()
	GameManager.ui.phone_overlay.visible = false
	_phone_ui.modulate.a = 0.0


func get_prompt() -> String:
	return "[E] Use"


func execute(_k: ActionKey) -> void:
	if _busy:
		return
	
	_busy = true
	GameManager.interact_mode(true)
	
	if _has_used:
		var line = _next_post_use_line()
		ScriptManager.say({"text": line})
	else:
		_has_used = true
		
		await _slide_to(GameManager.player.hold_marker, Transform3D.IDENTITY, MOVE_TIME, Tween.EASE_OUT)
		GameManager.ui.phone_overlay.visible = true
		await _fade_inbox(1.0, FADE_TIME)
		await get_tree().create_timer(hold_duration).timeout

		await _fade_inbox(0.0, FADE_TIME)
		GameManager.ui.phone_overlay.visible = false
		await _slide_to(_home, _rest_local, MOVE_TIME, Tween.EASE_IN_OUT)

		ScriptManager.say({"text": "*sighs* ...Right"})
		
	await ScriptManager.idle
	_busy = false
	GameManager.interact_mode(false)


func _slide_to(new_parent: Node3D, target: Transform3D, time: float, ease_type: Tween.EaseType) -> void:
	_phone_root.reparent(new_parent)
	var t := create_tween()
	t.tween_property(_phone_root, "transform", target, time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(ease_type)
	await t.finished


func _fade_inbox(alpha: float, time: float) -> void:
	var t := create_tween()
	t.tween_property(_phone_ui, "modulate:a", alpha, time)
	await t.finished


func _next_post_use_line() -> String:
	if _line_idx == 0:
		_post_use_lines.shuffle()
	_line_idx = (_line_idx + 1) % _post_use_lines.size()
	return _post_use_lines[_line_idx]

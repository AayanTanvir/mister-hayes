class_name PhoneAction
extends InteractAction

const MOVE_TIME := 0.4
const FADE_TIME := 0.2

@export var _screen_mesh: MeshInstance3D
@export var _screen_viewport: SubViewport
@export var _inbox: Control
@export var _phone: Node3D
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
	_home = _phone.get_parent_node_3d()
	_rest_local = _phone.transform
	_setup_screen()
	_inbox.modulate.a = 0.0


func get_prompt() -> String:
	return "[E] Use"


func execute(_k: ActionKey) -> void:
	if _busy:
		return
	
	_busy = true
	GameManager.interact_mode(true)
	
	if _has_used:
		var line = _next_post_use_line()
		DialogueManager.say({"text": line})
	else:
		_has_used = true

		await _slide_to(GameManager.player.hold_marker, Transform3D.IDENTITY, MOVE_TIME, Tween.EASE_OUT)
		await _fade_inbox(1.0, FADE_TIME)
		await get_tree().create_timer(hold_duration).timeout

		_fade_inbox(0.0, FADE_TIME)  # not awaited on purpose. fades while it slides back
		await _slide_to(_home, _rest_local, MOVE_TIME, Tween.EASE_IN_OUT)

		DialogueManager.say({"text": "*sighs* ...Right"})
		
	await DialogueManager.idle
	_busy = false
	GameManager.interact_mode(false)


func _slide_to(new_parent: Node3D, target: Transform3D, time: float, ease_type: Tween.EaseType) -> void:
	_phone.reparent(new_parent)
	var t := create_tween()
	t.tween_property(_phone, "transform", target, time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(ease_type)
	await t.finished


func _fade_inbox(alpha: float, time: float) -> void:
	var t := create_tween()
	t.tween_property(_inbox, "modulate:a", alpha, time)
	await t.finished

 
func _setup_screen() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = _screen_viewport.get_texture()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_screen_mesh.set_surface_override_material(0, mat)


func _next_post_use_line() -> String:
	if _line_idx == 0:
		_post_use_lines.shuffle()
	_line_idx = (_line_idx + 1) % _post_use_lines.size()
	return _post_use_lines[_line_idx]

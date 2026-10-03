extends InteractableComponent

@export var screen_mesh: MeshInstance3D
@export var screen_viewport: SubViewport
@export var inbox: Control
@export_range(1.0, 10.0, 0.5) var hold_duration: float = 2.0
@onready var parent: Node3D = get_parent() as Node3D

var home: Node3D
var rest_local: Transform3D
var busy := false


func _ready() -> void:
	prompt = "[E] Use"

	home = parent.get_parent_node_3d()
	rest_local = parent.transform

	var mat := StandardMaterial3D.new()
	mat.albedo_texture = screen_viewport.get_texture()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen_mesh.set_surface_override_material(0, mat)
	inbox.modulate.a = 0.0


func interact(_interact_key: InteractableComponent.INTERACT_KEY) -> void:
	if busy: return
	busy = true
	GameManager.set_interact_mode(true, false)

	# Attach to the marker (stays visually in place), then slide to its origin
	parent.reparent(GameManager.player.hold_marker)

	var t := create_tween()
	t.tween_property(parent, "transform", Transform3D.IDENTITY, 0.6) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(inbox, "modulate:a", 1.0, 0.3)
	
	t.tween_interval(hold_duration)
	
	t.tween_callback(_return_home)
	t.tween_property(inbox, "modulate:a", 0.0, 0.2)


func _return_home() -> void:
	# Re-attach to the car (stays visually in place), then slide back to rest
	parent.reparent(home)

	var t := create_tween()
	t.tween_property(parent, "transform", rest_local, 0.5) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(_finish)


func _finish() -> void:
	DialogueManager.say({"speaker": "Ethan", "text": "*sighs* ...Right"})
	busy = false
	GameManager.set_interact_mode(false, false)

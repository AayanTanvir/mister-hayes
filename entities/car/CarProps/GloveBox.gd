extends InteractableComponent

@export var glove_box_mesh: MeshInstance3D
@export var closed_collision: CollisionShape3D
@export var opened_collision: CollisionShape3D
@export_range(75.0, 120.0) var rotate_angle := 90.0
var _is_opened = false
var _closed_prompt = "Open [E]"
var _opened_prompt = "Close [E]"

func _ready() -> void:
	prompt = _closed_prompt
	opened_collision.disabled = true
	closed_collision.disabled = false

func interact() -> void:
	if not _is_opened:
		glove_box_mesh.rotate_object_local(Vector3.RIGHT, deg_to_rad(-rotate_angle))
		_is_opened = true
		prompt = _opened_prompt
		opened_collision.disabled = false
		closed_collision.disabled = true
	else:
		glove_box_mesh.rotate_object_local(Vector3.RIGHT, deg_to_rad(rotate_angle))
		_is_opened = false
		prompt = _closed_prompt
		opened_collision.disabled = true
		closed_collision.disabled = false

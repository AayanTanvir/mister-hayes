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
	var target_angle = deg_to_rad(rotate_angle if _is_opened else -rotate_angle)
	glove_box_mesh.rotate_object_local(Vector3.RIGHT, target_angle)
	_is_opened = not _is_opened
	prompt = _opened_prompt if _is_opened else _closed_prompt 
	opened_collision.disabled = not _is_opened
	closed_collision.disabled = _is_opened

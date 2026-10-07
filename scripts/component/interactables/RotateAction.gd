class_name RotateAction
extends InteractAction

enum RotateAxis {X, Y, Z}

@export var _mesh: MeshInstance3D
@export var _interact_area: Area3D
@export var _rotate_axis: RotateAxis = RotateAxis.X
@export_range(5.0, 360.0, 5.0) var _rotate_angle := 90.0
@export var _normal_prompt := "[E] Open"
@export var _rotated_prompt := "[E] Close"

var _rotated := false
var _prompt := "[E] Open"


func get_prompt() -> String:
	return _prompt


func execute(_k: ActionKey) -> void:
	var target_angle = deg_to_rad(-_rotate_angle if _rotated else _rotate_angle)
	_mesh.rotate_object_local(_get_vector_axis(_rotate_axis), target_angle)
	# Also rotate the collision
	_interact_area.rotate_object_local(_get_vector_axis(_rotate_axis), target_angle)
	_rotated = not _rotated
	
	_prompt = _rotated_prompt if _rotated else _normal_prompt
	prompt_changed.emit()


func _get_vector_axis(rotate_axis: RotateAxis) -> Vector3:
	match rotate_axis:
		RotateAxis.X:
			return Vector3.RIGHT
		RotateAxis.Y:
			return Vector3.UP
		RotateAxis.Z:
			return Vector3.BACK
		_:
			return Vector3.RIGHT

## Implements basic rotation for interaction. Inherits from InteractableComponent.
## Can be extended to implement further logic by using super.interact() and super.ready()
## in the inheriting script.
class_name RotateInteractable
extends InteractableComponent

enum RotateAxis {X, Y, Z}

@export var _mesh: MeshInstance3D
@export var _rotate_axis: RotateAxis = RotateAxis.X
@export_range(5.0, 360.0, 5.0) var _rotate_angle := 90.0
@export var _rotate_self := false	## Rotates the object the script is attached to along with the mesh
@export var _normal_prompt := "[E] Open\n"
@export var _rotated_prompt := "[E] Close\n"

var rotated := false
var extended_prompt := ""


func _ready() -> void:
	if not _mesh:
		push_error("Mesh not provided.")
	
	prompt = _normal_prompt + extended_prompt


## Inheriting scripts should use super.interact() first for implementing further logic.
func interact(interact_key: INTERACT_KEY) -> void:
	if interact_key == InteractableComponent.INTERACT_KEY.E:
		var target_angle = deg_to_rad(-_rotate_angle if rotated else _rotate_angle)
		_mesh.rotate_object_local(_get_vector_axis(_rotate_axis), target_angle)
		if _rotate_self:
			rotate_object_local(_get_vector_axis(_rotate_axis), target_angle)
			
		rotated = not rotated
	
	change_interact_prompt((_rotated_prompt if rotated else _normal_prompt) + extended_prompt)


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

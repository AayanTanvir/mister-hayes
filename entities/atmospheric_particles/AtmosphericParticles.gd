extends GPUParticles3D

@export var _fallback_target: Node3D	# fallback if no camera is active
@export var _forward_offset := 0.0


func _ready() -> void:
	top_level = true
	local_coords = false


func _process(_delta: float) -> void:
	var pos: Vector3
	var cam := get_viewport().get_camera_3d()
	if cam:
		var basis := cam.global_transform.basis
		pos = cam.global_position + (-basis.z) * _forward_offset
	elif _fallback_target:
		pos = _fallback_target.global_position
	else:
		return

	global_position = pos
	(process_material as ShaderMaterial).set_shader_parameter("anchor", global_position)

extends Camera3D

@export var target_rotation := Vector3(40.0, -120.0, 0.0)

@onready var route := get_parent() as DroneCamRoute
var rotate_speed := 0.07


func _process(delta: float) -> void:
	if route == null or route.running == false or delta <= 0.0:
		return
	
	#global_rotation.y = move_toward(global_rotation.y, target_rotation.y, rotate_speed * delta)
	#global_rotation.x = move_toward(global_rotation.x, target_rotation.x, rotate_speed * delta)
	#global_rotation.z = deg_to_rad(0.0)

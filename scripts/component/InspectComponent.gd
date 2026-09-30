class_name InspectComponent
extends Node3D

var inspect_point: Marker3D
var _rest_pos: Vector3
var _rest_rotation: Vector3

var _inspecting := false
var rotate_speed := 2.0


func _ready() -> void:
	_rest_pos = global_position
	_rest_rotation = global_rotation
	var player := GameManager.get_current_node(Player) as Player
	inspect_point = player.inspect_point


func _process(delta: float) -> void:
	if _inspecting:
		if Input.is_action_just_pressed("interact_F"):
			_stop_inspect()
			return
		
		var input := Input.get_vector("left", "right", "backward", "forward")
		
		if input.x:
			var target = input.x + rotation.y 
			rotation.y = lerpf(rotation.y, target, rotate_speed * delta)
		if input.y:
			var target = input.y + rotation.x
			rotation.x = lerpf(rotation.x, target, rotate_speed * delta)


func inspect():
	GameManager.set_inspection_mode(true)
	global_position = inspect_point.global_position
	_inspecting = true


func _stop_inspect():
	GameManager.set_inspection_mode(false)
	global_position = _rest_pos
	global_rotation = _rest_rotation
	_inspecting = false

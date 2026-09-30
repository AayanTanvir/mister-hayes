class_name InspectionViewer
extends CanvasLayer

@export var rotate_speed := 2.0
@export var wheel_factor := 0.9        # each wheel notch = 10% closer/further
@export var key_speed := 1.2           # held-key zoom speed (relative to distance)
@export var zoom_smoothing := 10.0
@export var zoom_min := 0.3
@export var zoom_max := 3.0

@onready var camera: Camera3D = %Camera3D
@onready var pivot: Node3D = %Pivot

var _model: Node3D
var _target_z := 0.5


func _ready() -> void:
	hide()
	set_process(false)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_z *= wheel_factor
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_z /= wheel_factor  


func _process(delta: float) -> void:
	var zoom_input := Input.get_axis("zoom_out", "zoom_in")
	_target_z -= zoom_input * key_speed * _target_z * delta
	_target_z = clampf(_target_z, zoom_min, zoom_max)
	camera.position.z = lerpf(camera.position.z, _target_z, 1.0 - exp(-zoom_smoothing * delta))
	
	var input := Input.get_vector("left", "right", "backward", "forward")
	if input == Vector2.ZERO:
		return
		
	var cam_basis := camera.global_transform.basis
	var pivot_basis := pivot.global_transform.basis
	pivot_basis = pivot_basis.rotated(cam_basis.y, input.x * rotate_speed * delta)
	pivot_basis = pivot_basis.rotated(cam_basis.x, -input.y * rotate_speed * delta)
	pivot.global_transform.basis = pivot_basis.orthonormalized()


func open(scene: PackedScene) -> void:
	_model = scene.instantiate()
	pivot.add_child(_model)
	pivot.transform = Transform3D.IDENTITY
	_model.transform = Transform3D.IDENTITY
	_center_model()
	show()
	set_process(true)
	
	_target_z = 0.5
	camera.position.z = _target_z
	camera.near = 0.01 

func close() -> void:
	_model.queue_free()
	hide()
	set_process(false)


func _center_model() -> void:
	var box := AABB()
	var first := true
	for mi: MeshInstance3D in _model.find_children("*", "MeshInstance3D", true, false):
		var b := mi.global_transform * mi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	_model.global_position -= box.get_center()
	# optional: pivot.scale = Vector3.ONE * (0.4 / box.get_longest_axis_size())

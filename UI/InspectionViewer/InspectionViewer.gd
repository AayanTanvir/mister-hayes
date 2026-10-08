class_name InspectionViewer
extends CanvasLayer

@export var rotate_speed := 2.0
@export var wheel_factor := 0.9
@export var key_speed := 1.2

@export_group("Zoom (relative)")
@export var default_margin := 0.8      # higher = starts further back
@export var min_zoom_factor := 0.5     # closest distance, as a fraction of the model's radius
@export var max_zoom_factor := 2.5     # furthest distance, as a multiple of the default distance
@export var zoom_smoothing := 10.0

@onready var camera: Camera3D = %Camera3D
@onready var pivot: Node3D = %Pivot

var _model: Node3D
var _target_z := 0.5
var _zoom_min := 0.1
var _zoom_max := 3.0


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
	
	if event is InputEventKey and event.is_action_pressed("esc"):
		GameManager.paused_interact_mode(false)
		close()


func _process(delta: float) -> void:
	var zoom_input := Input.get_axis("zoom_out", "zoom_in")
	_target_z -= zoom_input * key_speed * _target_z * delta
	_target_z = clampf(_target_z, _zoom_min, _zoom_max)
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
	GameManager.paused_interact_mode(true)
	
	_model = scene.instantiate()
	pivot.add_child(_model)
	pivot.transform = Transform3D.IDENTITY
	_model.transform = Transform3D.IDENTITY
	var radius := _center_model()

	var fit_distance := radius / sin(deg_to_rad(camera.fov * 0.5))
	var default_z := fit_distance * default_margin

	_zoom_min = radius * min_zoom_factor
	_zoom_max = default_z * max_zoom_factor
	_target_z = default_z
	camera.position.z = _target_z
	camera.near = _zoom_min * 0.25

	show()
	set_process(true)


func close() -> void:
	_model.queue_free()
	hide()
	set_process(false)


func _center_model() -> float:
	var box := AABB()
	var first := true
	for mi: MeshInstance3D in _model.find_children("*", "MeshInstance3D", true, false):
		var b := mi.global_transform * mi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	if first:
		return 0.5   # fall back to a sane size
	_model.global_position -= box.get_center()
	return box.size.length() * 0.5

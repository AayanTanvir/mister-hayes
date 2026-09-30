class_name DroneCamRoute
extends PathFollow3D

signal finished

var running := false
var _done := false
@onready var _curve: Curve3D = (get_parent() as Path3D).curve

@export_range(1.0, 5.0, 0.2) var speed := 2.0

func _ready() -> void:
	loop = false
	rotation_mode = PathFollow3D.ROTATION_XY


func start() -> void:
	running = true


func _process(delta: float) -> void:
	if not running or _done:
		return
	
	var remaining := _curve.get_baked_length() - progress
	progress += speed * delta
	
	if remaining < 0.1:
		_done = true
		running = false
		speed = 0.0
		finished.emit()

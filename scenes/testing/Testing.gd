extends Node3D

@export var start_in_car := false

@export_group("Nodes")
@export var car: CarCabinFX
@export var player: Player
@export var ui: UI


func _ready() -> void:
	player.interact_controller.interactable_detected.connect(ui._on_interactable_detected)
	
	if start_in_car:
		player.seat_in(car.seat)
		player.camera.make_current()
		player.set_look_enabled(true)

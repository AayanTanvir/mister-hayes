extends Node3D

@export var start_in_car := false
@export var car: CarCabinFX

var player: Player
var ui: UI


func _ready() -> void:
	player = GameManager.get_current_node(Player)
	ui = GameManager.get_current_node(UI)
	
	if start_in_car:
		player.seat_in(car.seat)
		player.camera.make_current()
		player.set_look_enabled(true)
	

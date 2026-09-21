class_name Prototype
extends Node

signal car_interacted(entered: bool)

@onready var player: Player = $Player
@onready var car: InteractableComponent = $Car/CarHandler
@onready var player_interact_controller: InteractController = $Player/InteractController
@onready var car_interact_controller: InteractController = $Car/InteractController
@onready var ui: UI = $UI


func _ready() -> void:
	# crosshair fade
	player_interact_controller.interactable_detected.connect(
		ui._on_interactable_detected
	)
	car_interact_controller.interactable_detected.connect(
		ui._on_interactable_detected
	)
	
	car_interacted.connect(player._on_car_interacted)


func set_car_interacted(entered: bool):
	car_interacted.emit(entered)
	if not entered:
		player.global_position = car.exit_point.global_position
		player.global_rotation = car.exit_point.global_rotation

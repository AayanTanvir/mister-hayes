extends Control

@export var outer_radius := 4.0
@export var inner_radius := 1.5
@export var thickness := 1.0


func _ready() -> void:
	modulate.a = 0.0


func _draw() -> void:
	var center := size / 2.0

	draw_circle(center, inner_radius, Color.WHITE)

	draw_arc(
		center,
		outer_radius,
		0.0,
		TAU,
		32,
		Color.WHITE,
		thickness
	)

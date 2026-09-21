class_name UI
extends CanvasLayer

@onready var crosshair: Control = $Control/Crosshair
var crosshair_tween: Tween
@export_range(0.1, 0.5, 0.02) var crosshair_fade_duration := 0.15


func _on_interactable_detected(detected: bool) -> void:
	if crosshair_tween: crosshair_tween.kill()
	
	crosshair_tween = create_tween()
	
	var alpha = 1.0 if detected else 0.0
	crosshair_tween.tween_property(crosshair, "modulate:a", alpha, crosshair_fade_duration)

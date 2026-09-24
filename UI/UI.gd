class_name UI
extends CanvasLayer

@export var crosshair_handler: Control
@export var interact_prompt: Label
var interact_prompt_tween: Tween


func _ready() -> void:
	interact_prompt.text = ""
	interact_prompt.modulate.a = 0.0


func _on_interactable_detected(detected: bool, prompt: String) -> void:
	crosshair_handler.show_interact_crosshair(detected)
	set_prompt(prompt)


func set_prompt(prompt: String):
	if not prompt: 
		interact_prompt.text = ""
		interact_prompt.modulate.a = 0.0
	else:
		if interact_prompt_tween: interact_prompt_tween.kill()
		
		interact_prompt.text = prompt
		interact_prompt_tween = create_tween()
		interact_prompt_tween.tween_property(interact_prompt, "modulate:a", 1.0, crosshair_handler.fade_duration)


func set_hud_visible(set_visible: bool):
	crosshair_handler.set_crosshair_visible(set_visible)

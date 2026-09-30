@abstract class_name InteractableComponent
extends Area3D

enum INTERACT_KEY {E, F}

@export var interact_keys: Array[INTERACT_KEY] = [INTERACT_KEY.E]
var prompt = ""


@abstract func interact(interact_key: INTERACT_KEY) -> void


func change_interact_prompt(new_prompt: String):
	if prompt == new_prompt:
		return
	
	prompt = new_prompt
	GameManager.update_interact_prompt(new_prompt)

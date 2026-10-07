class_name Interactable
extends Area3D

var _actions: Array[InteractAction] = []
var focused := false


func _ready() -> void:
	for child in get_children():
		if child is InteractAction:
			_actions.append(child)
			child.prompt_changed.connect(_on_prompt_changed)


func has_key(key: InteractAction.ActionKey) -> bool:
	return _actions.any(func(a: InteractAction) -> bool: return a.handles(key))


func interact(key: InteractAction.ActionKey) -> void:
	for action in _actions:
		if action.handles(key):
			action.execute(key)


func get_prompt() -> String:
	return "\n".join(_actions.map(func(a: InteractAction) -> String: return a.get_prompt()))


func _on_prompt_changed() -> void:
	if focused:
		GameManager.ui.set_interact_prompt(get_prompt())

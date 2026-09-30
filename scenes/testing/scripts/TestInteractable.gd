extends InteractableComponent


func _ready() -> void:
	prompt = "Test Interactable"


func interact(_interact_key: InteractableComponent.INTERACT_KEY) -> void:
	print("[TEST INTERACTABLE]")

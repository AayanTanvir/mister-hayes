extends InteractableComponent

var parent: InspectComponent


func _ready() -> void:
	prompt = "[E] Inspect"
	parent = get_parent() as InspectComponent


func interact(_interact_key: InteractableComponent.INTERACT_KEY) -> void:
	parent.inspect()

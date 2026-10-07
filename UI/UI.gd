class_name UI
extends CanvasLayer

@onready var inspection_viewer: InspectionViewer = %InspectionViewer
@onready var text_viewer: TextViewer = %TextViewer
@onready var interact_prompt_container: Control = %InteractPromptContainer
@onready var interact_prompt: Label = %InteractPrompt
@onready var crosshair: TextureRect = %Crosshair

@export var dialogue_container: Control
@export var dialogue_label: RichTextLabel


func _ready() -> void:
	interact_prompt.text = ""
	interact_prompt_container.visible = false


func _on_interactable_detected(_detected: bool, prompt: String) -> void:
	set_interact_prompt(prompt)


func set_interact_prompt(prompt: String = ""):
	interact_prompt.text = prompt
	interact_prompt_container.visible = not not prompt


func set_hud_visible(show_hud: bool, change_interact_prompt: bool = false):
	crosshair.visible = show_hud
	if change_interact_prompt:
		interact_prompt_container.visible = show_hud

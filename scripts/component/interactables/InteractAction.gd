@abstract class_name InteractAction
extends Node

signal prompt_changed

enum ActionKey {E, F}

## When this key is pressed, the action is executed. By default its E.
## For multiple action keys, overwrite [code]handles(k: ActionKey)[/code]
## [codeblock]
## # This uses both E and F, then uses the key parameter in execute to handle accordingly
## func handles(k: ActionKey) -> bool:
##     return k == ActionKey.E or k == ActionKey.F
## [/codeblock]
@export var key: ActionKey = ActionKey.E


func handles(k: ActionKey) -> bool:
	return key == k

@abstract func get_prompt() -> String
@abstract func execute(k: ActionKey) -> void

extends Node

signal state_changed(key: String, value: Variant)

var section := "intro"
var state: Dictionary = {}


func set_state(key: String, value: Variant = true) -> void:
	state[key] = value
	state_changed.emit(key, value)


func get_state(key: String, default: Variant = false) -> Variant:
	return state.get(key, default)


func to_dict() -> Dictionary:
	return {"version": 1, "section": section, "state": state}


func from_dict(d: Dictionary) -> void:
	section = d.get("section", "intro")
	state = d.get("state", {})


#func save_game(slot := 1) -> void:
	#var f := FileAccess.open("user://save_%d.json" % slot, FileAccess.WRITE)
	#f.store_string(JSON.stringify(to_dict()))

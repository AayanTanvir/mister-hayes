class_name EngineAudio
extends AudioStreamPlayer3D

const BUS := &"Engine"
const OUTSIDE_CUTOFF := 20500.0
const INSIDE_CUTOFF := 700.0
const INSIDE_VOLUME_DB := -8.0
const OUTSIDE_VOLUME_DB := 6.0


func set_inside(inside: bool) -> void:
	var b := AudioServer.get_bus_index(BUS)
	var lp := AudioServer.get_bus_effect(b, 0) as AudioEffectLowPassFilter
	lp.cutoff_hz = INSIDE_CUTOFF if inside else OUTSIDE_CUTOFF
	AudioServer.set_bus_volume_db(b, INSIDE_VOLUME_DB if inside else OUTSIDE_VOLUME_DB)
	

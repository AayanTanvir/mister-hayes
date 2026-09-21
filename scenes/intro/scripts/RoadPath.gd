@tool
class_name RoadPath
extends Path3D
## Path3D with a one-click "Smooth handles" button in the inspector.
## Place points roughly, click the button, and the road turns into smooth curves
## instead of sharp corners (which would make the steering wheel snap).
## Save the scene afterwards.

@export_tool_button("Smooth handles") var smooth_handles_button := smooth_handles


func smooth_handles() -> void:
	if curve == null or curve.point_count < 3:
		return

	var n := curve.point_count
	for i in n:
		var p := curve.get_point_position(i)
		var to_prev := Vector3.ZERO
		var to_next := Vector3.ZERO
		if curve.closed or i > 0:
			to_prev = curve.get_point_position(posmod(i - 1, n)) - p
		if curve.closed or i < n - 1:
			to_next = curve.get_point_position(posmod(i + 1, n)) - p

		# direction of travel through the point; handle lengths follow the neighbouring
		# segment lengths so short segments don't overshoot
		var tangent := (to_next.normalized() - to_prev.normalized()).normalized()
		curve.set_point_in(i, -tangent * to_prev.length() / 3.0)
		curve.set_point_out(i, tangent * to_next.length() / 3.0)

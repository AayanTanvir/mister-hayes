@tool
extends MeshInstance3D
class_name RoadMeshGenerator

## SETUP:
## 1. Add a MeshInstance3D as a DIRECT CHILD of your RoadPath (Path3D) node.
## 2. Attach this script to that MeshInstance3D (leave RoadPath.gd on the Path3D untouched).
## 3. Set the exports below and assign a material.
##
## WHY THIS FIXES THE OFFSET BUG:
## Because this node is a child of the Path3D, it inherits the Path3D's exact
## transform automatically. curve.sample_baked() returns points in the Path3D's
## OWN local space -- the same space this mesh lives in -- so there is no
## conversion, no "Path Local" toggle, and no way for the two to drift apart.

@export var road_width: float = 6.0
@export var width_tiles: float = 1.0       ## how many texture tiles should fit across the road's width
@export var tile_length: float = 4.0       ## real-world meters ONE texture tile should cover along the road
@export var bake_interval: float = 1.0     ## distance between mesh cross-sections; lower = smoother curves, more tris
@export var road_material: Material
@export var generate_collision: bool = false
@export var regenerate: bool = false:
	set(value):
		if value:
			generate()

func _ready() -> void:
	generate()
	# Auto-regenerate in the editor whenever the curve is edited, so you never
	# have to remember to hit "regenerate" by hand.
	if Engine.is_editor_hint():
		var path := get_parent() as Path3D
		if path and path.curve and not path.curve.changed.is_connected(generate):
			path.curve.changed.connect(generate)

func generate() -> void:
	var path := get_parent() as Path3D
	if path == null:
		push_error("RoadMeshGenerator must be a direct child of a Path3D node.")
		return
	var curve := path.curve
	if curve == null or curve.point_count < 2:
		push_warning("Path3D has no curve, or fewer than 2 points.")
		return

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var total_length: float = curve.get_baked_length()
	var steps: int = max(2, int(total_length / bake_interval))
	var half_width: float = road_width * 0.5

	var prev_left: Vector3
	var prev_right: Vector3
	var prev_v: float = 0.0
	var has_prev: bool = false

	for i in range(steps + 1):
		var dist: float = total_length * float(i) / float(steps)
		var pos: Vector3 = curve.sample_baked(dist)

		# Estimate the tangent by sampling a hair ahead on the curve.
		var sample_ahead: float = min(dist + 0.05, total_length)
		var ahead: Vector3 = curve.sample_baked(sample_ahead)
		var forward: Vector3 = ahead - pos
		if forward.length() < 0.0001:
			forward = Vector3.FORWARD
		forward = forward.normalized()

		var right: Vector3 = forward.cross(Vector3.UP)
		if right.length() < 0.0001:
			right = Vector3.RIGHT
		right = right.normalized()

		var left_point: Vector3 = pos - right * half_width
		var right_point: Vector3 = pos + right * half_width

		# V is real accumulated distance divided by tile length -- it never
		# resets per-segment, so the texture never stretches along the road
		# no matter how bake_interval or curve density change.
		var v: float = dist / tile_length

		if has_prev:
			st.set_uv(Vector2(0.0, prev_v));         st.add_vertex(prev_left)
			st.set_uv(Vector2(width_tiles, prev_v)); st.add_vertex(prev_right)
			st.set_uv(Vector2(0.0, v));               st.add_vertex(left_point)

			st.set_uv(Vector2(width_tiles, prev_v)); st.add_vertex(prev_right)
			st.set_uv(Vector2(width_tiles, v));       st.add_vertex(right_point)
			st.set_uv(Vector2(0.0, v));               st.add_vertex(left_point)

		prev_left = left_point
		prev_right = right_point
		prev_v = v
		has_prev = true

	st.generate_normals()
	st.generate_tangents()
	mesh = st.commit()

	if road_material:
		material_override = road_material

	if generate_collision:
		_rebuild_collision()

func _rebuild_collision() -> void:
	for child in get_children():
		if child is StaticBody3D and child.name == "RoadCollision":
			child.queue_free()

	var static_body := StaticBody3D.new()
	static_body.name = "RoadCollision"
	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = mesh.create_trimesh_shape()
	static_body.add_child(collision_shape)
	add_child(static_body)

	if Engine.is_editor_hint() and get_tree().edited_scene_root:
		static_body.owner = get_tree().edited_scene_root
		collision_shape.owner = get_tree().edited_scene_root

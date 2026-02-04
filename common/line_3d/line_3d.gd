@icon("uid://bq0gmimspb2tm")
class_name Line3D
extends GeometryInstance3D
@export var color := Color.WHITE
@export var points: PackedVector3Array = []
@export var width := 0.5:
	set(w):
		var diff := width - w
		width = w
		for segment: MeshInstance3D in _segments:
			var mesh: CapsuleMesh = segment.mesh
			mesh.radius = width / 2
			mesh.height -= diff
@export var material: BaseMaterial3D
var _segments: Array[MeshInstance3D] = []

@warning_ignore("shadowed_variable_base_class")
func add_point(position: Vector3, index := -1) -> void:
	index = posmod(index, len(points) + 1)
	points.insert(index, position)

	if len(points) < 2:
		return

	var segment: MeshInstance3D
	match index:
		0:
			segment = _create_segment(position, points[1])
			add_child(segment)
			move_child(segment, 0)
			_segments.insert(0, segment)
		index when index == len(points) - 1:
			segment = _create_segment(points[index - 1], position)
			add_child(segment)
			_segments.append(segment)
		_:
			var prev_point := points[index - 1]
			var next_point := points[index + 1]
			var prev_segment := _segments[index - 1]
			_place_segment(prev_segment, prev_point, position)
			segment = _create_segment(position, next_point)
			prev_segment.add_sibling(segment)
			_segments.insert(index, segment)


func clear_points() -> void:
	points.clear()
	for segment: MeshInstance3D in _segments:
		if is_instance_valid(segment):
			segment.queue_free()
	_segments.clear()


func get_point_count() -> int:
	return len(points)


func get_point_position(index: int) -> Vector3:
	return points[index]


func remove_point(index: int) -> void:
	index = posmod(index, len(points))
	points.remove_at(index)
	if len(_segments) > index:
		_segments.pop_at(index).queue_free()
		set_point_position(index, points[index])
	elif len(_segments) == index:
		_segments.pop_back().queue_free()


@warning_ignore("shadowed_variable_base_class")
func set_point_position(index: int, position: Vector3) -> void:
	index = posmod(index, len(points))
	points[index] = position
	if index != 0:
		_place_segment(_segments[index - 1], points[index - 1], position)
	if index != len(points) - 1:
		_place_segment(_segments[index], position, points[index + 1])


func redraw() -> void:
	for segment: MeshInstance3D in _segments:
		if is_instance_valid(segment):
			segment.queue_free()
	_segments.clear()

	if len(points) < 2:
		return

	for index in range(len(points) - 1):
		var start := points[index]
		var end := points[index + 1]
		var mesh_instance := _create_segment(start, end)
		add_child(mesh_instance, false, Node.INTERNAL_MODE_DISABLED)
		_segments.append(mesh_instance)


func _create_segment(start: Vector3, end: Vector3) -> MeshInstance3D:
	var mesh := CapsuleMesh.new()
	mesh.radius = width / 2
	mesh.material = material

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh

	_place_segment(mesh_instance, start, end)

	var transfer := false
	for property: Dictionary in get_property_list():
		var prop_name: String = property.get("name")
		var usage: int = property.get("usage", PROPERTY_USAGE_NONE)
		if usage & PROPERTY_USAGE_CATEGORY:
			transfer = prop_name in ["VisualInstance3D", "GeometryInstance3D"]
		elif (
			transfer
			and usage & PROPERTY_USAGE_DEFAULT == PROPERTY_USAGE_DEFAULT
		):
			if prop_name == "script":
				continue
			mesh_instance.set(prop_name, self.get(prop_name))

	return mesh_instance


func _place_segment(
	segment: MeshInstance3D, start: Vector3, end: Vector3
) -> void:
	var difference := end - start
	if difference.is_zero_approx():
		segment.hide()
		return
	segment.position = start + (difference / 2)
	segment.quaternion = Quaternion(Vector3.UP, difference.normalized())
	segment.mesh.height = max(difference.length() + width, 2 * width)

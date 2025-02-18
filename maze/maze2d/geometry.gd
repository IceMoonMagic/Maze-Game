extends Node2D

var raw_points: Array[Vector2i] = []
@onready var start_marker: Line2D = $StartPoint
@onready var end_marker: Line2D = start_marker.duplicate()


func _ready() -> void:
	add_child(end_marker)
	update_line_options()
	Globals.options_applied.connect(update_line_options)


func _draw() -> void:
	if not MazeData.wall_options.enabled or len(raw_points) == 0:
		return
	var points: Array[Vector2] = []
	for i in range(0, len(raw_points), 2):
		points.append_array(adjust_points(raw_points[i], raw_points[i + 1]))
	draw_multiline(
		points, MazeData.wall_options.color, MazeData.wall_options.thickness
	)


func adjust_points(start: Vector2i, end: Vector2i) -> Array[Vector2]:
	"""Scales points to TILE_SIZE and offsets to manually make caps"""
	var offset := MazeData.wall_options.thickness / 2
	if Vector2(start).angle_to_point(end) == 0:  # If horizontal line
		return [
			Vector2(start) * MazeData.TILE_SIZE + Vector2.LEFT * offset,
			Vector2(end) * MazeData.TILE_SIZE + Vector2.RIGHT * offset
		]
	else:  # If vertical line
		return [
			Vector2(start) * MazeData.TILE_SIZE + Vector2.UP * offset,
			Vector2(end) * MazeData.TILE_SIZE + Vector2.DOWN * offset
		]


func update_line_options() -> void:
	queue_redraw()
	for goal: Line2D in [start_marker, end_marker]:
		goal.visible = MazeData.goal_options.enabled
		goal.default_color = MazeData.goal_options.color
		goal.width = MazeData.goal_options.thickness


func new_maze(walls: Array[Vector2i], start_end: Array[Vector2i]) -> void:
	raw_points = walls

	queue_redraw()

	# Set Start and End
	start_marker.position = (
		Vector2(start_end[0]) * MazeData.TILE_SIZE
		+ Vector2.ONE * MazeData.TILE_SIZE / 2
	)
	end_marker.position = (
		Vector2(start_end[1]) * MazeData.TILE_SIZE
		+ Vector2.ONE * MazeData.TILE_SIZE / 2
	)

extends Node3D

var raw_points: Array[Vector2i] = []
@onready var floor_collision: CollisionShape3D = $Floor/FloorCollision
@onready var floor_mesh_instance: MeshInstance3D = $Floor/FloorMeshInstance
@onready var wall_geometry: Node3D = $Walls
@onready var base_wall: StaticBody3D = $Walls/BaseWall
@onready var start_goal: Area3D = $StartGoal
@onready var end_goal: Area3D = start_goal.duplicate(12)


func _ready() -> void:
	start_goal.add_sibling(end_goal)
	end_goal.name = "EndGoal"
	end_goal.monitoring = true
	end_goal.connect("body_entered", func(body: Node3D) -> void: print(body))
	new_maze(
		Vector2i(8, 5),
		[
			Vector2i(2, 2),
			Vector2i(2, 2) + Vector2i.DOWN,
			Vector2i(2, 1),
			Vector2i(2, 1) + Vector2i.DOWN,
			Vector2i(2, 2),
			Vector2i(2, 2) + Vector2i.RIGHT
		],
		[Vector2i(3, 1), Vector2i(3, 3)]
	)


func new_maze(
	dimensions: Vector2i, walls: Array[Vector2i], start_end: Array[Vector2i]
) -> void:
	raw_points = walls
#
	var modified := Vector2(dimensions) * MazeData.TILE_SIZE

	var floor_mesh: PlaneMesh = floor_mesh_instance.mesh
	floor_mesh.size = modified
	floor_mesh.center_offset = Vector3(modified.x / 2, 0, modified.y / 2)

	var floor_collision_box: BoxShape3D = floor_collision.shape
	floor_collision_box.size = Vector3(modified.x, 0, modified.y)
	floor_collision.position = floor_mesh.center_offset

	for child: Node3D in wall_geometry.get_children():
		if "@" in child.name:
			print("Freeing ", child.name)
			child.queue_free()

	for i: int in range(0, len(walls), 2):
		var start := walls[i]
		var end := walls[i + 1]
		var center := (
			Vector2(start * MazeData.TILE_SIZE + end * MazeData.TILE_SIZE) / 2
		)
		var direction := (walls[i + 1] - walls[i]).abs()

		var wall := base_wall.duplicate()
		wall.position = Vector3(center.x, 0, center.y)
		if direction == Vector2i.DOWN:
			wall.rotate_y(deg_to_rad(90))
		wall_geometry.add_child(wall)

	var start := start_end[0] * MazeData.TILE_SIZE
	start_goal.position.x = start.x
	start_goal.position.z = start.y
	var end := start_end[1] * MazeData.TILE_SIZE
	end_goal.position.x = end.x
	end_goal.position.z = end.y

extends Node3D

var raw_points: Array[Vector2i] = []
@onready var floor_collision: CollisionShape3D = $Floor/FloorCollision
@onready var floor_mesh_instance: MeshInstance3D = $Floor/FloorMeshInstance


func _ready() -> void:
	new_maze(Vector2i.ONE * 5 + Vector2i.RIGHT * 3, [], [])


func new_maze(
	dimensions: Vector2i, walls: Array[Vector2i], _start_end: Array[Vector2i]
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

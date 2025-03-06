extends Node3D

var walls: Array[Vector2i] = []
@onready var floor_collision: CollisionShape3D = $Floor/FloorCollision
@onready var floor_mesh_instance: MeshInstance3D = $Floor/FloorMeshInstance
@onready var wall_geometry: Node3D = $Walls
@onready var base_wall: StaticBody3D = $Walls/BaseWall
@onready
var wall_mesh_instance: MeshInstance3D = $Walls/BaseWall/WallMeshInstance
@onready var end_goal: Area3D = $EndGoal
@onready var end_goal_mesh_instance: MeshInstance3D = $EndGoal/MeshInstance3D
@onready var start_goal: Area3D = end_goal.duplicate(12)
@onready var start_goal_mesh_instance: MeshInstance3D = start_goal.get_node(
	"MeshInstance3D"
)
@onready var world_environment: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
	end_goal.add_sibling(start_goal)
	start_goal.name = "StartGoal"
	start_goal.monitoring = false
	Globals.options_applied.connect(build_walls)
	Globals.options_applied.connect(update_colors)
	update_colors()


func update_colors() -> void:
	floor_mesh_instance.mesh.surface_get_material(0).albedo_color = (
		MazeData.background_options.color
	)
	end_goal_mesh_instance.mesh.surface_get_material(0).albedo_color = (
		MazeData.goal_options.color
	)
	end_goal.get_node("BeaconMeshInstance").mesh.surface_get_material(0).albedo_color = (
		MazeData.goal_options.color
	)
	end_goal.get_node("BeaconMeshInstance").mesh.surface_get_material(0).albedo_color.a8 = 128
	world_environment.environment.background_mode = (
		Environment.BG_CLEAR_COLOR
		if MazeData.maze_3d_options.flat
		else Environment.BG_SKY
	)


func build_walls() -> void:
	for child: Node3D in wall_geometry.get_children():
		if "@" in child.name:
			#print("Freeing ", child.name)
			child.queue_free()

	wall_mesh_instance.mesh.size.y = MazeData.maze_3d_options.wall_height
	wall_mesh_instance.position.y = MazeData.maze_3d_options.wall_height / 2
	wall_mesh_instance.mesh.surface_get_material(0).albedo_color = (
		MazeData.wall_options.color
	)

	for i: int in range(0, len(walls), 2):
		var start := walls[i]
		var end := walls[i + 1]
		var center := (
			Vector2(start * MazeData.TILE_SIZE + end * MazeData.TILE_SIZE) / 2
		)
		var as_vector := Vector2(walls[i + 1] - walls[i]).abs()
		var direction := as_vector.normalized()

		var wall := base_wall.duplicate()
		wall.visible = true
		wall.position = Vector3(center.x, 0, center.y)
		if as_vector.length() > 1:
			var mesh_instance: MeshInstance3D = wall.get_node(
				"WallMeshInstance"
			)
			mesh_instance.mesh = mesh_instance.mesh.duplicate()
			mesh_instance.mesh.size.z = (
				as_vector.length() * MazeData.TILE_SIZE
				+ mesh_instance.mesh.size.x
			)
			var collision: CollisionShape3D = wall.get_node("WallCollision")
			collision.shape = collision.shape.duplicate()
			collision.shape.size.z = mesh_instance.mesh.size.z
		if direction == Vector2.RIGHT:
			wall.rotate_y(deg_to_rad(90))
		wall_geometry.add_child(wall)


func new_maze(
	dimensions: Vector2i, new_walls: Array[Vector2i], start_end: Array[Vector2i]
) -> void:  #
	var modified := Vector2(dimensions) * MazeData.TILE_SIZE

	var floor_mesh: PlaneMesh = floor_mesh_instance.mesh
	floor_mesh.size = modified
	floor_mesh.center_offset.x = modified.x / 2
	floor_mesh.center_offset.z = modified.y / 2

	var floor_collision_box: BoxShape3D = floor_collision.shape
	floor_collision_box.size = Vector3(modified.x, 0, modified.y)
	floor_collision.position = floor_mesh.center_offset

	walls = new_walls
	build_walls()

	var start_pos := (
		Vector2(start_end[0]) * MazeData.TILE_SIZE
		+ Vector2.ONE * MazeData.TILE_SIZE / 2
	)
	start_goal.position.x = start_pos.x
	start_goal.position.z = start_pos.y
	var end_pos := (
		Vector2(start_end[1]) * MazeData.TILE_SIZE
		+ Vector2.ONE * MazeData.TILE_SIZE / 2
	)
	end_goal.position.x = end_pos.x
	end_goal.position.z = end_pos.y

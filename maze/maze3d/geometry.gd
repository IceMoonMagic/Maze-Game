extends Node3D

const WALL_TEXTURE: Texture2D = preload("res://maze/maze3d/assets/rocky2.png")
const FLOOR_TEXTURE: Texture2D = preload(
	"res://maze/maze3d/assets/stones_angular.png"
)
const TILE_LIGHTS: PackedScene = preload(
	"res://maze/maze3d/components/travel_indicator.tscn"
)

var walls: Array[Vector2i] = []
@onready var floor_collision: CollisionShape3D = $Floor/FloorCollision
@onready var floor_mesh_instance: MeshInstance3D = $Floor/FloorMeshInstance
@onready var wall_geometry: Node3D = $Walls
@onready var base_wall: StaticBody3D = $Walls/BaseWall
@onready
var wall_mesh_instance: MeshInstance3D = $Walls/BaseWall/WallMeshInstance
@onready
var wall_occluder: OccluderInstance3D = $Walls/BaseWall/WallMeshInstance/WallOccluder
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
	end_goal_mesh_instance.mesh.surface_get_material(0).albedo_color = (
		MazeOptions.goal_options.color
	)
	end_goal.get_node("BeaconMeshInstance").mesh.surface_get_material(0).albedo_color = (
		MazeOptions.goal_options.color
	)
	end_goal.get_node("BeaconMeshInstance").mesh.surface_get_material(0).albedo_color.a8 = 128

	var floor_material: BaseMaterial3D = (
		floor_mesh_instance.mesh.surface_get_material(0)
	)
	if MazeOptions.maze_3d_options.flat:
		floor_material.albedo_color = MazeOptions.background_options.color
		floor_material.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, null)
		floor_material.normal_enabled = false
		world_environment.environment.background_mode = (
			Environment.BG_CLEAR_COLOR
		)
	else:
		floor_material.albedo_color = Color.WHITE
		floor_material.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, FLOOR_TEXTURE)
		floor_material.normal_enabled = true
		world_environment.environment.background_mode = Environment.BG_SKY


func build_walls() -> void:
	for child: Node3D in wall_geometry.get_children():
		if "@" in child.name:
			#print("Freeing ", child.name)
			child.queue_free()

	wall_mesh_instance.mesh.size.y = MazeOptions.maze_3d_options.wall_height
	wall_occluder.occluder.size.y = MazeOptions.maze_3d_options.wall_height
	wall_mesh_instance.position.y = MazeOptions.maze_3d_options.wall_height / 2
	var wall_material: BaseMaterial3D = (
		wall_mesh_instance.mesh.surface_get_material(0)
	)

	if MazeOptions.maze_3d_options.flat:
		wall_material.albedo_color = MazeOptions.wall_options.color
		wall_material.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, null)
		wall_material.normal_enabled = false
	else:
		wall_material.albedo_color = Color.FOREST_GREEN
		wall_material.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, WALL_TEXTURE)
		wall_material.normal_enabled = true

	for i: int in range(0, len(walls), 2):
		var start := walls[i]
		var end := walls[i + 1]
		var center := (
			Vector2(start * MazeOptions.TILE_SIZE + end * MazeOptions.TILE_SIZE)
			/ 2
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
				as_vector.length() * MazeOptions.TILE_SIZE
				+ mesh_instance.mesh.size.x
			)
			var collision: CollisionShape3D = wall.get_node("WallCollision")
			collision.shape = collision.shape.duplicate()
			collision.shape.size.z = mesh_instance.mesh.size.z
		if direction == Vector2.RIGHT:
			wall.rotate_y(deg_to_rad(90))
		wall_geometry.add_child(wall)


func new_maze(maze: Maze) -> void:
	var dimensions := maze.dimensions
	var new_walls := maze.walls

	var modified := Vector2(dimensions) * MazeOptions.TILE_SIZE
	var floor_mesh: PlaneMesh = floor_mesh_instance.mesh
	floor_mesh.size = modified
	floor_mesh.center_offset.x = modified.x / 2
	floor_mesh.center_offset.z = modified.y / 2
	floor_mesh.surface_get_material(0).uv1_scale = (
		Vector3(dimensions.x, dimensions.y, 0) * 4
	)

	var floor_collision_box: BoxShape3D = floor_collision.shape
	floor_collision_box.size = Vector3(modified.x, 0, modified.y)
	floor_collision.position = floor_mesh.center_offset

	walls = new_walls
	build_walls()

	var start_pos := (
		Vector2(maze.start) * MazeOptions.TILE_SIZE
		+ Vector2.ONE * MazeOptions.TILE_SIZE / 2
	)
	start_goal.position.x = start_pos.x
	start_goal.position.z = start_pos.y
	var end_pos := (
		Vector2(maze.end) * MazeOptions.TILE_SIZE
		+ Vector2.ONE * MazeOptions.TILE_SIZE / 2
	)
	end_goal.position.x = end_pos.x
	end_goal.position.z = end_pos.y

	var parent: Node3D = $TravelIndicators
	for indicator: Node in parent.get_children():
		indicator.queue_free()
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			var cell := Vector2i(x, y)
			var lights: TravelIndicator = TILE_LIGHTS.instantiate()
			lights.light_locations = (
				(
					lights.Locations.FORWARD
					* int(!maze.can_travel_in(cell, Vector2i.UP))
				)
				+ (
					lights.Locations.BACKWARD
					* int(!maze.can_travel_in(cell, Vector2i.DOWN))
				)
				+ (
					lights.Locations.LEFT
					* int(!maze.can_travel_in(cell, Vector2i.LEFT))
				)
				+ (
					lights.Locations.RIGHT
					* int(!maze.can_travel_in(cell, Vector2i.RIGHT))
				)
			)
			lights.position = (
				Vector3(x, 0, y) * MazeOptions.TILE_SIZE
				+ Vector3(1, 0, 1) * MazeOptions.TILE_SIZE / 2
			)
			parent.add_child(lights)


func reset_indicators() -> void:
	for indicator: Node3D in $TravelIndicators.get_children():
		if indicator is TravelIndicator:
			indicator.active = false

class_name Maze3D
extends Node3D

signal show_menu
var maze := Maze.new()
@onready var geometry: Node3D = $Geometry
@onready var player: CharacterBody3D = $Player


func new_maze() -> void:
	maze.choose_cell_weights = MazeOptions.config.generation_options.weights
	maze.dimensions = MazeOptions.config.generation_options.dimensions
	if maze.dimensions == Vector2i.ZERO:
		pass
	elif maze.dimensions.x == 0:
		maze.dimensions.x = maze.dimensions.y
	elif maze.dimensions.y == 0:
		maze.dimensions.y = maze.dimensions.x
	maze.new_maze(maze.dimensions)
	apply()
	restart()


func apply() -> void:
	geometry.new_maze(maze)


func restart() -> void:
	player.reset_to(geometry.get_node("StartGoal").position)
	# The cell the player was in before registers the body_entered,
	# so gotta wait for that to process then undo it.
	await get_tree().physics_frame
	await get_tree().physics_frame
	geometry.reset_indicators()


func _on_player_maze_end(_arg: Variant) -> void:
	show_menu.emit()

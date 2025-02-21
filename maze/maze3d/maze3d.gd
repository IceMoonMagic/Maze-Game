class_name Maze3D
extends Node3D

signal show_menu
var maze := Maze.new()


func new_maze() -> void:
	maze.choose_cell_weights = MazeData.generation_options.weights
	maze.dimensions = MazeData.generation_options.dimensions
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
	assert(maze.grid is Array[Array])
	# `Invalid type` if done inline, for some reason
	var start_end: Array[Vector2i] = [maze.start, maze.end]
	$Geometry.new_maze(maze.dimensions, maze.walls, start_end)


func restart() -> void:
	$Player.position = $Geometry/StartGoal.position


func _on_player_maze_end(_arg: Variant) -> void:
	show_menu.emit()

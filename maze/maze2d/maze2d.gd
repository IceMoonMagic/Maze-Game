class_name Maze2D
extends Node2D

signal show_menu
enum ReplayMode { EXPLORED_PATH, FINAL_PATH }
var maze := Maze.new()


func new_maze() -> void:
	maze.choose_cell_weights = MazeData.generation_options.weights
	maze.dimensions = MazeData.generation_options.dimensions
	if (
		get_viewport_rect().size.aspect() < 1
		and (
			(
				get_parent()
				. get_node("%Menu/OptionsMenu")
				. get_node("%GenerationOptions")
				. auto_mode_label
				. text
			)
			== "Fit"
		)
	):
		maze.dimensions = Vector2(maze.dimensions.y, maze.dimensions.x)
	if maze.dimensions == Vector2i.ZERO:
		pass
	elif maze.dimensions.x == 0:
		maze.dimensions.x = $Camera2D.will_fit(maze.dimensions.y).x
	elif maze.dimensions.y == 0:
		maze.dimensions.y = $Camera2D.will_fit(maze.dimensions.x).y
	maze.new_maze(maze.dimensions)
	apply()
	restart()


func apply() -> void:
	assert(maze.grid is Array[Array])
	# `Invalid type` if done inline, for some reason
	var start_end: Array[Vector2i] = [maze.start, maze.end]
	$Geometry.new_maze(maze.walls, start_end)
	$Camera2D.new_maze(maze.dimensions)


func restart() -> void:
	$Player.reset_to(maze.start, maze.end)


func _on_player_maze_end() -> void:
	show_menu.emit()


func replay_path(mode: ReplayMode) -> void:
	var path: PackedVector2Array
	match mode:
		ReplayMode.EXPLORED_PATH:
			path = $Player/ExploredLine.points
		ReplayMode.FINAL_PATH:
			path = $Player/FinalLine.points
	$Player.replay_path(path)

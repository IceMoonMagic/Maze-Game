extends Node

const TILE_SIZE := 7

var cursor_options: LineOptionData = (
	preload("res://maze/maze2d/options/default_options/cursor_options.tres")
	. duplicate()
)
var main_trail_options: LineOptionData = (
	preload("res://maze/maze2d/options/default_options/main_trail_options.tres")
	. duplicate()
)
var explored_trail_options: LineOptionData = (
	preload(
		"res://maze/maze2d/options/default_options/explored_trail_options.tres"
	)
	. duplicate()
)
var wall_options: LineOptionData = (
	preload("res://maze/maze2d/options/default_options/wall_options.tres")
	. duplicate()
)
var goal_options: LineOptionData = (
	preload("res://maze/maze2d/options/default_options/goal_options.tres")
	. duplicate()
)
var background_options: LineOptionData = (
	preload("res://maze/maze2d/options/default_options/background_options.tres")
	. duplicate()
)
var generation_options: GenerationOptionData = (
	preload("res://maze/maze2d/options/default_options/generation_options.tres")
	. duplicate()
)
var maze_3d_options: Maze3DOptions = (
	preload("res://maze/maze3d/default_options/maze_3d_options.tres")
	. duplicate()
)

var config_file := ConfigFile.new()
var config_json := JSON.new()


func _ready() -> void:
	Globals.options_applied.connect(save_config_file)
	Globals.options_applied.connect(
		func() -> void:
			RenderingServer.set_default_clear_color(background_options.color)
	)


func load_config_file() -> Error:
	var err := config_file.load("user://config.cfg")
	if err != OK:
		return err

	cursor_options.enabled = config_file.get_value(
		"Appearance", "cursor.enabled", cursor_options.enabled
	)
	cursor_options.color = config_file.get_value(
		"Appearance", "cursor.color", cursor_options.color
	)
	cursor_options.thickness = config_file.get_value(
		"Appearance", "cursor.thickness", cursor_options.thickness
	)
	main_trail_options.enabled = config_file.get_value(
		"Appearance", "main_trail.enabled", main_trail_options.enabled
	)
	main_trail_options.color = config_file.get_value(
		"Appearance", "main_trail.color", main_trail_options.color
	)
	main_trail_options.thickness = config_file.get_value(
		"Appearance", "main_trail.thickness", main_trail_options.thickness
	)
	explored_trail_options.enabled = config_file.get_value(
		"Appearance", "explored_trail.enabled", explored_trail_options.enabled
	)
	explored_trail_options.color = config_file.get_value(
		"Appearance", "explored_trail.color", explored_trail_options.color
	)
	explored_trail_options.thickness = config_file.get_value(
		"Appearance",
		"explored_trail.thickness",
		explored_trail_options.thickness
	)
	wall_options.enabled = config_file.get_value(
		"Appearance", "wall.enabled", wall_options.enabled
	)
	wall_options.color = config_file.get_value(
		"Appearance", "wall.color", wall_options.color
	)
	wall_options.thickness = config_file.get_value(
		"Appearance", "wall.thickness", wall_options.thickness
	)
	goal_options.enabled = config_file.get_value(
		"Appearance", "goal.enabled", goal_options.enabled
	)
	goal_options.color = config_file.get_value(
		"Appearance", "goal.color", goal_options.color
	)
	goal_options.thickness = config_file.get_value(
		"Appearance", "goal.thickness", goal_options.thickness
	)
	background_options.color = config_file.get_value(
		"Appearance", "background", background_options.color
	)

	if (
		maze_3d_options == null
		and config_file.has_section_key("Appearance", "maze3d.flat")
		and config_file.has_section_key("Appearance", "maze3d.wall_height")
	):
		maze_3d_options = Maze3DOptions.new()
		config_file.get_value("Appearance", "maze3d.flat")
		config_file.get_value("Appearance", "maze3d.wall_height")
	elif maze_3d_options != null:
		maze_3d_options.flat = config_file.get_value(
			"Appearance", "maze3d.flat", maze_3d_options.flat
		)
		maze_3d_options.wall_height = config_file.get_value(
			"Appearance", "maze3d.wall_height", maze_3d_options.wall_height
		)

	generation_options.weights = config_file.get_value(
		"Generation", "weights", generation_options.weights
	)
	generation_options.dimensions = config_file.get_value(
		"Generation", "dimensions", generation_options.dimensions
	)

	print(OS.get_user_data_dir())
	Globals.options_applied.emit()
	return OK


func save_config_file() -> Error:
	config_file.set_value(
		"Appearance", "cursor.enabled", cursor_options.enabled
	)
	config_file.set_value("Appearance", "cursor.color", cursor_options.color)
	config_file.set_value(
		"Appearance", "cursor.thickness", cursor_options.thickness
	)
	config_file.set_value(
		"Appearance", "main_trail.enabled", main_trail_options.enabled
	)
	config_file.set_value(
		"Appearance", "main_trail.color", main_trail_options.color
	)
	config_file.set_value(
		"Appearance", "main_trail.thickness", main_trail_options.thickness
	)
	config_file.set_value(
		"Appearance", "explored_trail.enabled", explored_trail_options.enabled
	)
	config_file.set_value(
		"Appearance", "explored_trail.color", explored_trail_options.color
	)
	config_file.set_value(
		"Appearance",
		"explored_trail.thickness",
		explored_trail_options.thickness
	)
	config_file.set_value("Appearance", "wall.enabled", wall_options.enabled)
	config_file.set_value("Appearance", "wall.color", wall_options.color)
	config_file.set_value(
		"Appearance", "wall.thickness", wall_options.thickness
	)
	config_file.set_value("Appearance", "goal.enabled", goal_options.enabled)
	config_file.set_value("Appearance", "goal.color", goal_options.color)
	config_file.set_value(
		"Appearance", "goal.thickness", goal_options.thickness
	)
	config_file.set_value("Appearance", "background", background_options.color)

	if maze_3d_options != null:
		config_file.set_value("Appearance", "maze3d.flat", maze_3d_options.flat)
		config_file.set_value(
			"Appearance", "maze3d.wall_height", maze_3d_options.wall_height
		)

	config_file.set_value("Generation", "weights", generation_options.weights)
	config_file.set_value(
		"Generation", "dimensions", generation_options.dimensions
	)

	print(OS.get_user_data_dir())
	return config_file.save("user://config.cfg")

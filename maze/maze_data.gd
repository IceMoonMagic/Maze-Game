extends Node

const TILE_SIZE := 7


class GenerationOptionData:
	var breadth_weight: float
	var depth_weight: float
	var random_weight: float
	var weights: Array[float]:
		get:
			return [breadth_weight, depth_weight, random_weight]
		set(new_weights):
			breadth_weight = new_weights[0]
			depth_weight = new_weights[1]
			random_weight = new_weights[2]
	var dimensions: Vector2i

	func _init(
		breadth: float, depth: float, random: float, p_dimensions: Vector2i
	) -> void:
		breadth_weight = breadth
		depth_weight = depth
		random_weight = random
		dimensions = p_dimensions

	func is_valid() -> bool:
		return (
			breadth_weight + depth_weight + random_weight != 0
			and dimensions != Vector2i.ZERO
		)

	func equals(other: GenerationOptionData) -> bool:
		return (
			self.breadth_weight == other.breadth_weight
			and self.depth_weight == other.depth_weight
			and self.random_weight == other.random_weight
			and self.dimensions == other.dimensions
		)

	func set_to(other: GenerationOptionData) -> void:
		self.breadth_weight = other.breadth_weight
		self.depth_weight = other.depth_weight
		self.random_weight = other.random_weight
		self.dimensions = other.dimensions


class LineOptionData:
	var enabled: bool
	var color: Color
	var thickness: float

	func _init(p_enabled: bool, p_color: Color, p_thickness: float) -> void:
		self.enabled = p_enabled
		self.color = p_color
		self.thickness = p_thickness

	func equals(other: LineOptionData) -> bool:
		return (
			self.enabled == other.enabled
			and self.color == other.color
			and self.thickness == other.thickness
		)

	func set_to(other: LineOptionData) -> void:
		self.enabled = other.enabled
		self.color = other.color
		self.thickness = other.thickness


class Maze3DOptions:
	var flat: bool
	var wall_height: float

	func _init(
		p_flat: bool,
		p_wall_height: float,
	) -> void:
		flat = p_flat
		wall_height = p_wall_height

	func equals(other: Maze3DOptions) -> bool:
		return (
			self.flat == other.flat
			and self.wall_height == other.wall_height
		)

	func set_to(other: Maze3DOptions) -> void:
		self.flat = other.flat
		self.wall_height = other.wall_height


var cursor_options: LineOptionData
var main_trail_options: LineOptionData
var explored_trail_options: LineOptionData
var wall_options: LineOptionData
var goal_options: LineOptionData
var background_options: LineOptionData
var generation_options: GenerationOptionData
var maze_3d_options: Maze3DOptions

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
		maze_3d_options = (
			Maze3DOptions
			. new(
				config_file.get_value("Appearance", "maze3d.flat"),
				config_file.get_value("Appearance", "maze3d.wall_height"),
			)
		)
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

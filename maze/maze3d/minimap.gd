extends CanvasLayer

var maze: Maze:
	get:
		return maze_2d.maze
	set(new_maze):
		maze_2d.maze = new_maze

@onready var maze_2d: Maze2D = %Maze2D
@onready var cursor: Line2D = maze_2d.get_node("Player")
@onready var background: ColorRect = $ColorRect
@onready var player: CharacterBody3D = $"../Player"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Still want to use some parts of it's processing, so can't just pause it
	maze_2d.set_process_input(false)
	maze_2d.get_node("Camera2D").set_process_input(false)
	cursor.set_process_input(false)
	Globals.options_applied.connect(update_background)
	Globals.options_applied.connect(update_size)
	update_background()


func _physics_process(_delta: float) -> void:
	var curr_position := Vector2(
		player.position.x - fposmod(player.position.x, MazeData.TILE_SIZE),
		player.position.z - fposmod(player.position.z, MazeData.TILE_SIZE)
	)
	if (
		curr_position == cursor.position
		or (len(cursor.path) > 0 and cursor.path[-1] == curr_position)
	):
		return

	cursor.path.append(curr_position)
	cursor.prune_path()


func apply() -> void:
	maze_2d.apply()
	background.size = maze.dimensions * MazeData.TILE_SIZE


func restart() -> void:
	maze_2d.restart()


func update_background() -> void:
	background.color = MazeData.background_options.color


func update_size() -> void:
	var target := (
		get_viewport().get_visible_rect().size
		* (MazeData.maze_3d_options.minimap_size / 100.0)
	)
	var multiplier: Vector2 = target / background.size
	scale = Vector2.ONE * min(multiplier.x, multiplier.y)

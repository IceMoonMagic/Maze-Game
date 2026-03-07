extends Line2D

signal maze_end
@export var base_speed := MazeOptions.TILE_SIZE * 2  # 2 Cells / Second
var speed: float
var path: Array[Vector2]
var end_goal: Vector2
var accept_input: bool = false
var _allow_drag_event: bool = true
var _is_clone: bool = false
var _clone: Line2D = null
@onready var explored_line := $ExploredLine
@onready var final_line := $FinalLine


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _is_clone:
		return
	# Resize & Reposition cursor
	for i in range(len(self.points)):
		self.set_point_position(
			i, (self.points[i] + Vector2.ONE) * MazeOptions.TILE_SIZE / 4
		)

	# Offset to center of cells
	var lines_offset := Vector2.ONE * MazeOptions.TILE_SIZE / 2
	explored_line.position = lines_offset
	final_line.position = lines_offset

	update_line_options()
	Globals.options_applied.connect(update_line_options)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move(delta)


func _input(event: InputEvent) -> void:
	if not accept_input:
		return
	# Use event.get_action_strength(...) == 1
	# to get discreet inputs from joysticks
	if event.get_action_strength("Move - Up") == 1:
		add_path(Vector2i.UP)
	elif event.get_action_strength("Move - Down") == 1:
		add_path(Vector2i.DOWN)
	elif event.get_action_strength("Move - Left") == 1:
		add_path(Vector2i.LEFT)
	elif event.get_action_strength("Move - Right") == 1:
		add_path(Vector2i.RIGHT)
	elif event is InputEventScreenDrag:
		if (
			not _allow_drag_event
			or event.screen_relative.length_squared() < 16 ** 2
		):
			return
		var vel: Vector2 = event.screen_relative
		const ACCEPTABLE_ANGLE = PI / 6  # +- 30 Degrees
		for direction: Vector2 in [
			Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT
		]:
			if absf(direction.angle_to(vel)) < ACCEPTABLE_ANGLE:
				add_path(direction)
				_allow_drag_event = false
				return
		_allow_drag_event = false
	elif event is InputEventScreenTouch and event.pressed:
		_allow_drag_event = true


func move(delta: float) -> void:
	if position == end_goal and (accept_input or _is_clone):
		maze_end.emit()
		accept_input = false
	if path.is_empty():
		speed = base_speed
		return

	var adjusted_speed := delta * speed
	position -= (position - path[0]).clampf(-adjusted_speed, adjusted_speed)

	# If going to point already on the final_line, remove prev stop
	if len(final_line.points) > 2 and path[0] == final_line.points[-3]:
		final_line.remove_point(len(final_line.points) - 2)
	explored_line.set_point_position(len(explored_line.points) - 1, position)
	final_line.set_point_position(len(final_line.points) - 1, position)

	if path[0] == position:
		path.pop_front()
		# if point not on line (ignoring -1) (avoids adding point when back tracking)
		if position != end_goal:
			explored_line.add_point(position)
		else:
			# Add to both as explored can be configured to be bigger than final
			explored_line.end_cap_mode = Line2D.LINE_CAP_BOX
			final_line.end_cap_mode = Line2D.LINE_CAP_BOX
		if (
			not (
				len(final_line.points) >= 2
				and final_line.points[-2] == position
			)
			and position != end_goal
		):
			final_line.add_point(position)
		return


func add_route(route: Array[Vector2i]) -> void:
	var adjusted := route.map(
		func(val: Vector2i) -> Vector2:
			return Vector2(val) * MazeOptions.TILE_SIZE
	)
	path.append_array(adjusted)
	prune_path()
	calc_speed()


func solve_maze(maze: Maze) -> void:
	accept_input = false
	var solve_from: Vector2i
	if path.is_empty():
		solve_from = Vector2i(position / MazeOptions.TILE_SIZE)
	else:
		solve_from = Vector2i(path[-1] / MazeOptions.TILE_SIZE)
	var route := maze.route_to_end(solve_from)
	add_route(route)
	speed = min(speed, base_speed ** 2)


func add_path(direction: Vector2) -> void:
	var reference: Vector2 = position if path.is_empty() else path[-1]
	reference /= MazeOptions.TILE_SIZE
	var target := reference + direction
	if not get_parent().maze.can_travel_in(reference, direction):
		return

	var branch: Array[Vector2i] = get_parent().maze.follow_branch(
		reference, target
	)
	add_route(branch)


func prune_path() -> void:
	#return
	if len(path) <= 1:
		return

	for i in range(len(path)):
		# if position is between path[i-1] and path[i]
		if (
			i > 0
			and (
				path[i - 1].angle_to_point(position)
				== position.angle_to_point(path[i])
			)
		):
			path = path.slice(i)
			return
		elif path[i] in path.slice(i + 1):
			var prev_instance := path.rfind(path[i])
			path = path.slice(0, i) + path.slice(prev_instance)
			prune_path()  # Reset for loop
			return


func calc_speed() -> void:
	var prev_speed := speed
	speed = 0
	if len(path) == 0:
		return

	var ref := position
	for cell: Vector2 in path:
		speed += ref.distance_to(cell) * 1.5
		ref = cell
	speed = max(speed, prev_speed)


func update_line_options() -> void:
	self.visible = MazeOptions.config.cursor_options.enabled
	self.default_color = MazeOptions.config.cursor_options.color
	self.width = MazeOptions.config.cursor_options.thickness
	final_line.visible = MazeOptions.config.main_trail_options.enabled
	final_line.default_color = MazeOptions.config.main_trail_options.color
	final_line.width = MazeOptions.config.main_trail_options.thickness
	explored_line.visible = MazeOptions.config.explored_trail_options.enabled
	# Blend the transparency to avoid issues with stacked transparent layers
	explored_line.default_color = (
		MazeOptions
		. config
		. background_options
		. color
		. blend(MazeOptions.config.explored_trail_options.color)
	)
	explored_line.width = MazeOptions.config.explored_trail_options.thickness


func reset_to(start: Vector2i, end: Vector2i) -> void:
	_clear_clone()
	path.clear()
	position = start * MazeOptions.TILE_SIZE
	end_goal = end * MazeOptions.TILE_SIZE
	explored_line.clear_points()
	explored_line.add_point(position)
	explored_line.add_point(position)
	explored_line.end_cap_mode = Line2D.LINE_CAP_NONE
	final_line.clear_points()
	final_line.add_point(position)
	final_line.add_point(position)
	final_line.end_cap_mode = Line2D.LINE_CAP_NONE
	accept_input = true


func replay_path(play_path: Array[Vector2]) -> void:
	if len(play_path) < 1:
		return

	_clone = self.duplicate(12)
	_clone._is_clone = true
	add_sibling(_clone)
	_clone.reset_to(
		play_path[0] / MazeOptions.TILE_SIZE,
		play_path[-1] / MazeOptions.TILE_SIZE
	)
	play_path[-1] = (
		floor(play_path[-1] / MazeOptions.TILE_SIZE) * MazeOptions.TILE_SIZE
	)
	_clone.path = play_path
	_clone.calc_speed()
	_clone.speed = min(_clone.speed, base_speed ** 2)
	_clone.accept_input = false

	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false

	await _clone.maze_end
	_clear_clone()


func _clear_clone() -> void:
	if not _clone:
		return

	_clone.queue_free()
	_clone = null
	process_mode = ProcessMode.PROCESS_MODE_PAUSABLE
	visible = true

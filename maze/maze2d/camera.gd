extends Camera2D

@export var max_zoom := 15.0
var min_zoom := 1.0
var maze_dimensions: Vector2i
var _max_zoom := max_zoom


func _process(_delta: float) -> void:
	var pan: Vector2 = Input.get_vector(
		"Camera - Left", "Camera - Right", "Camera - Up", "Camera - Down"
	)
	if pan != Vector2.ZERO:
		_input_pan(pan)

	var zoom_mod: float = Input.get_axis("Zoom - Out", "Zoom - In")
	if zoom_mod != 0:
		_input_zoom(zoom_mod)


func _input(event: InputEvent) -> void:
	if (
		event.is_action_pressed("Zoom - In")
		or event.is_action_pressed("Zoom - Out")
	):
		_input_zoom(Input.get_axis("Zoom - Out", "Zoom - In"))
	elif event is InputEventMouse:
		_input_mouse(event)

	elif event is InputEventMagnifyGesture:
		_input_zoom(1 - event.factor)
	elif event is InputEventPanGesture:
		_input_pan(event.delta)


func _input_mouse(event: InputEventMouse) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		else:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	elif (
		event is InputEventMouseMotion
		and Input.mouse_mode == Input.MOUSE_MODE_CONFINED_HIDDEN
	):
		_input_pan(event.relative * -0.5)


func _input_zoom(amount: float) -> void:
	zoom = (zoom + Vector2.ONE * amount).clampf(min_zoom, _max_zoom)
	_set_limits()


func _input_pan(pos_delta: Vector2) -> void:
	var viewport_half := get_viewport_rect().size / zoom / 2

	var limit_top_left := Vector2(limit_left, limit_top) + viewport_half
	var limit_bottom_right := Vector2(limit_right, limit_bottom) - viewport_half

	position = (position + pos_delta).clamp(limit_top_left, limit_bottom_right)


func will_fit(n: int) -> Vector2i:
	var size := get_viewport_rect().size
	var ratio_x := size.x / size.y
	var ratio_y := size.y / size.x
	return Vector2i(roundi(ratio_x * n), roundi(ratio_y * n))


func new_maze(dimensions: Vector2i) -> void:
	maze_dimensions = dimensions * MazeData.TILE_SIZE
	reset()
	_max_zoom = maxf(zoom.x, max_zoom)


func reset() -> void:
	position = maze_dimensions / 2
	var view_size := get_viewport_rect().size
	var new_size := minf(
		view_size.x / (maze_dimensions.x + MazeData.wall_options.thickness),
		view_size.y / (maze_dimensions.y + MazeData.wall_options.thickness)
	)
	min_zoom = new_size
	zoom = Vector2.ONE * new_size
	_set_limits()
	reset_smoothing()


func _set_limits() -> void:
	var view_size: Vector2 = get_viewport_rect().size / zoom
	var target_size := Vector2(maze_dimensions)
	# Pad so external walls don't get cropped by limits when zoomed in
	target_size += Vector2.ONE * MazeData.wall_options.thickness
	# How much to push the limits out to center maze
	var margins: Vector2 = (view_size - target_size).max(Vector2.ZERO)
	# Reduce both axes by smaller axis (such that smaller becomes zero)
	margins -= Vector2.ONE * margins[margins.min_axis_index()]

	var limit_offsets: Vector2 = (target_size + margins) / 2
	var center: Vector2i = maze_dimensions / 2
	limit_left = ceili(center.x - limit_offsets.x)
	limit_top = ceili(center.y - limit_offsets.y)
	limit_right = floori(center.x + limit_offsets.x)
	limit_bottom = floori(center.y + limit_offsets.y)

extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
# Input of 1 can do a 360 in 60 physics frames (1 sec)
const TURN_SPEED = deg_to_rad(360.0 / 60.0)

var _last_point := Vector3.ZERO


func _input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion:
		return
	$Camera3D.rotate_x(deg_to_rad(-event.relative.y * TURN_SPEED))
	$Camera3D.rotation.x = clampf(
		$Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90)
	)
	self.rotate_y(deg_to_rad(-event.relative.x * TURN_SPEED))


func _physics_process(delta: float) -> void:
	$Camera3D.rotate_x(
		Input.get_axis("Camera - Down", "Camera - Up") * TURN_SPEED
	)
	$Camera3D.rotation.x = clampf(
		$Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90)
	)
	self.rotate_y(
		Input.get_axis("Camera - Right", "Camera - Left") * TURN_SPEED
	)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Reset on out of bounds
	if position.y < -16:
		position = Vector3.UP * -position.y

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector(
		"Move - Left", "Move - Right", "Move - Up", "Move - Down"
	)
	var direction := (
		(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	_modify_line()


func reset_to(where: Vector3) -> void:
	global_position = where
	$Line3D.clear_points()
	$Line3D.add_point(where)  # Start in start goal
	$Line3D.add_point(Vector3(where.x, 0, where.z))  # Move to ground
	$Line3D.add_point(where)  # "Attach" to player
	_last_point = $Line3D.points[-2]


func _modify_line() -> void:
	var tile: Vector2 = (
		(
			(
				Vector2(position.x, position.z)
				+ Vector2.ONE * MazeOptions.TILE_SIZE / 2
			)
			. snappedf(MazeOptions.TILE_SIZE)
		)
		- (MazeOptions.TILE_SIZE * Vector2.ONE / 2)
	)
	var tile_point := Vector3(tile.x, 0, tile.y)

	$Line3D.set_point_position(-1, Vector3(position.x, 0, position.z))

	# Same Tile
	if tile_point == _last_point:
		pass

	# Tile inline w/ prev, move prev node here
	elif $Line3D.points[-2].direction_to(_last_point).is_equal_approx(
		_last_point.direction_to(tile_point)
	):
		#$Line3D.set_point_position(-2, tile_point)
		_last_point = tile_point

	# Tile between prev1 / prev2, remove prev1
	elif $Line3D.points[-2].direction_to(_last_point).is_equal_approx(
		-_last_point.direction_to(tile_point)
	):
		$Line3D.remove_point(-2)
		_last_point = tile_point

	# Tile out of line
	else:
		$Line3D.add_point(_last_point, -2)
		_last_point = tile_point

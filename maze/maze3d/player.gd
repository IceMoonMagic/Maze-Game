extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
# Input of 1 can do a 360 in 60 physics frames (1 sec)
const TURN_SPEED = deg_to_rad(360.0 / 60.0)


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


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

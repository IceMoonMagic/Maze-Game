extends Control

@onready var flat_check: CheckButton = %FlatCheck
@onready var flat_reset: Button = %FlatReset
@onready var rotate_check: CheckButton = %RotateCheck
@onready var rotate_reset: Button = %RotateReset
@onready var wall_spin_box: SpinBox = %WallSpinBox
@onready var wall_reset: Button = %WallReset

## Default options set in the inspector
## DO NOT MODIFY
@onready var default_options := MazeData.Maze3DOptions.new(
	flat_check.button_pressed, rotate_check.button_pressed, wall_spin_box.value
)

## Options actively in use
@onready var applied_options := MazeData.Maze3DOptions.new(
	flat_check.button_pressed, rotate_check.button_pressed, wall_spin_box.value
)

## Modified but unsaved options
@onready var unapplied_options := MazeData.Maze3DOptions.new(
	flat_check.button_pressed, rotate_check.button_pressed, wall_spin_box.value
)


func set_to(option_data: MazeData.Maze3DOptions) -> void:
	unapplied_options.set_to(option_data)
	flat_check.button_pressed = unapplied_options.flat
	_on_flat_check_pressed()
	rotate_check.button_pressed = unapplied_options.rotation_lock
	_on_rotate_check_pressed()
	wall_spin_box.value = unapplied_options.wall_height
	_on_wall_spin_box_value_changed(wall_spin_box.value)


func _on_flat_check_pressed() -> void:
	unapplied_options.flat = flat_check.button_pressed
	flat_reset.disabled = unapplied_options.flat == default_options.flat


func _on_flat_reset_pressed() -> void:
	flat_check.button_pressed = default_options.flat
	_on_flat_check_pressed()


func _on_rotate_check_pressed() -> void:
	unapplied_options.rotation_lock = rotate_check.button_pressed
	rotate_reset.disabled = (
		unapplied_options.rotation_lock == default_options.rotation_lock
	)


func _on_rotate_reset_pressed() -> void:
	rotate_check.button_pressed = default_options.rotation_lock
	_on_rotate_check_pressed()


func _on_wall_spin_box_value_changed(value: float) -> void:
	unapplied_options.wall_height = value
	wall_reset.disabled = (
		unapplied_options.wall_height == default_options.wall_height
	)


func _on_wall_reset_pressed() -> void:
	wall_spin_box.value = default_options.wall_height
	_on_wall_spin_box_value_changed(default_options.wall_height)

extends Control

@export var default_options := Maze3DOptions.new():
	set(val):
		if (
			is_instance_valid(default_options)
			and default_options.changed.is_connected(
				set_to.bind(default_options)
			)
		):
			default_options.changed.disconnect(set_to.bind(default_options))
		default_options = val
		if (
			is_instance_valid(default_options)
			and not default_options.changed.is_connected(set_to)
		):
			default_options.changed.connect(set_to.bind(default_options))
			if not is_node_ready():
				await ready
			set_to(default_options)

@onready var flat_check: CheckButton = %FlatCheck
@onready var flat_reset: Button = %FlatReset
@onready var wall_spin_box: SpinBox = %WallSpinBox
@onready var wall_reset: Button = %WallReset

## Options actively in use
@onready var applied_options := MazeOptions.config.maze_3d_options

## Modified but unsaved options
@onready var unapplied_options := Maze3DOptions.new().set_to(applied_options)


func set_to(option_data: Maze3DOptions) -> void:
	if not is_node_ready():
		await ready
	unapplied_options.set_to(option_data)
	flat_check.button_pressed = unapplied_options.flat
	_on_flat_check_pressed()
	wall_spin_box.value = unapplied_options.wall_height
	_on_wall_spin_box_value_changed(wall_spin_box.value)


func _on_flat_check_pressed() -> void:
	unapplied_options.flat = flat_check.button_pressed
	flat_reset.disabled = unapplied_options.flat == default_options.flat


func _on_flat_reset_pressed() -> void:
	flat_check.button_pressed = default_options.flat
	_on_flat_check_pressed()


func _on_wall_spin_box_value_changed(value: float) -> void:
	unapplied_options.wall_height = value
	wall_reset.disabled = (
		unapplied_options.wall_height == default_options.wall_height
	)


func _on_wall_reset_pressed() -> void:
	wall_spin_box.value = default_options.wall_height
	_on_wall_spin_box_value_changed(default_options.wall_height)

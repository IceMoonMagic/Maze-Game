extends Control

signal leave_options_menu

@onready var cursor_options: LineOptionControl = %CursorOptions
@onready var main_trail_options: LineOptionControl = %MainTrailOptions
@onready var explored_trail_options: LineOptionControl = %ExploredTrailOptions
@onready var wall_options: LineOptionControl = %WallOptions
@onready var goal_options: LineOptionControl = %GoalOptions
@onready var background_options: LineOptionControl = %BackgroundOptions
@onready var generation_options: GenerationOptionControl = %GenerationOptions
@onready var leave_button: Button = $HBoxContainer/LeaveButton
@onready var revert_button: Button = $HBoxContainer/RevertButton
@onready var apply_button: Button = $HBoxContainer/ApplyButton


func _ready() -> void:
	cursor_options.applied_options = MazeOptions.cursor_options
	main_trail_options.applied_options = MazeOptions.main_trail_options
	explored_trail_options.applied_options = MazeOptions.explored_trail_options
	wall_options.applied_options = MazeOptions.wall_options
	goal_options.applied_options = MazeOptions.goal_options
	background_options.applied_options = MazeOptions.background_options
	generation_options.applied_options = MazeOptions.generation_options
	MazeOptions.load_config_file()
	cursor_options.set_to(MazeOptions.cursor_options)
	main_trail_options.set_to(MazeOptions.main_trail_options)
	explored_trail_options.set_to(MazeOptions.explored_trail_options)
	wall_options.set_to(MazeOptions.wall_options)
	goal_options.set_to(MazeOptions.goal_options)
	background_options.set_to(MazeOptions.background_options)
	generation_options.set_to(MazeOptions.generation_options)


func _on_timer_timeout() -> void:
	pass  # Replace with function body.
#func _process(_delta: float) -> void:
	var different: bool = false
	for line_option_control: LineOptionControl in [
		cursor_options,
		main_trail_options,
		explored_trail_options,
		wall_options,
		goal_options,
		background_options,
	]:
		different = (
			not line_option_control.applied_options.equals(
				line_option_control.unapplied_options
			)
			or different
		)
	different = (
		not generation_options.applied_options.equals(
			generation_options.unapplied_options
		)
		or different
	)

	leave_button.disabled = different
	revert_button.disabled = not different
	apply_button.disabled = not different


func _on_leave_button_pressed() -> void:
	leave_options_menu.emit()


func _on_revert_button_pressed() -> void:
	for line_option_control: LineOptionControl in [
		cursor_options,
		main_trail_options,
		explored_trail_options,
		wall_options,
		goal_options,
		background_options,
	]:
		line_option_control.set_to(line_option_control.applied_options)
	generation_options.set_to(generation_options.applied_options)
	_on_timer_timeout()


func _on_apply_button_pressed() -> void:
	for line_option_control: LineOptionControl in [
		cursor_options,
		main_trail_options,
		explored_trail_options,
		wall_options,
		goal_options,
		background_options,
	]:
		line_option_control.applied_options.set_to(
			line_option_control.unapplied_options
		)
	generation_options.applied_options.set_to(
		generation_options.unapplied_options
	)
	Globals.options_applied.emit()
	_on_timer_timeout()

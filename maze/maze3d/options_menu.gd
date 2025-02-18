extends Control

signal leave_options_menu

@onready var maze_2d_options_button: Button = %Maze2DOptionsButton
@onready var generation_options: GenerationOptionControl = %GenerationOptions
@onready var leave_button: Button = $HBoxContainer/LeaveButton
@onready var revert_button: Button = $HBoxContainer/RevertButton
@onready var apply_button: Button = $HBoxContainer/ApplyButton
@onready var _2d_options_menu: VBoxContainer = $"2DOptionsMenu"
@onready var _3d_maze_options: VBoxContainer = %"3DMazeOptions"


func _ready() -> void:
	var _2d_options_tabs: TabContainer = _2d_options_menu.get_node(
		"OptionsTabs"
	)
	_2d_options_tabs.tabs_visible = false
	# MazeData.load_config_file()  # Called by 2DOptionsMenu
	generation_options.applied_options = MazeData.generation_options
	generation_options.set_to(MazeData.generation_options)

	if MazeData.maze_3d_options == null:
		MazeData.maze_3d_options = _3d_maze_options.applied_options
	_3d_maze_options.applied_options = MazeData.maze_3d_options  # Ensures they are the same object
	_3d_maze_options.set_to(MazeData.maze_3d_options)


func _on_timer_timeout() -> void:
	pass  # Replace with function body.
#func _process(_delta: float) -> void:
	var different: bool = false
	different = (
		not generation_options.applied_options.equals(
			generation_options.unapplied_options
		)
		or not _3d_maze_options.applied_options.equals(
			_3d_maze_options.unapplied_options
		)
	)

	leave_button.disabled = different
	revert_button.disabled = not different
	apply_button.disabled = not different


func _on_leave_button_pressed() -> void:
	leave_options_menu.emit()


func _on_revert_button_pressed() -> void:
	generation_options.set_to(generation_options.applied_options)
	_3d_maze_options.set_to(_3d_maze_options.applied_options)

	_on_timer_timeout()


func _on_apply_button_pressed() -> void:
	generation_options.applied_options.set_to(
		generation_options.unapplied_options
	)
	_3d_maze_options.applied_options.set_to(_3d_maze_options.unapplied_options)
	Globals.options_applied.emit()


func _on_maze_2d_options_button_pressed() -> void:
	$OptionsTabs.visible = false
	$HBoxContainer.visible = false
	$"2DOptionsMenu".visible = true


func _on_2d_options_menu_leave_options_menu() -> void:
	$OptionsTabs.visible = true
	$HBoxContainer.visible = true
	$"2DOptionsMenu".visible = false

class_name MazeMenu
extends Control

signal resume_maze
signal restart_maze
signal replay_path(mode: Maze2D.ReplayMode)
signal new_maze
signal options_updated
signal quit
@onready var block_unpause: bool:
	get:
		return $OptionsMenu.visible


func _ready() -> void:
	pass
	$MarginContainer/MainMenu/NewMazeButton.grab_focus()


func on_has_maze(maze_exists: bool = true) -> void:
	$MarginContainer/MainMenu/ResumeButton.visible = maze_exists
	$MarginContainer/MainMenu/RestartButton.visible = maze_exists


func _on_resume_button_pressed() -> void:
	resume_maze.emit()


func _on_restart_button_pressed() -> void:
	restart_maze.emit()


func _on_replay_explored_button_pressed() -> void:
	replay_path.emit(Maze2D.ReplayMode.EXPLORED_PATH)


func _on_replay_final_button_pressed() -> void:
	replay_path.emit(Maze2D.ReplayMode.FINAL_PATH)


func _on_new_maze_button_pressed() -> void:
	new_maze.emit()


func _on_options_button_pressed() -> void:
	$MarginContainer.visible = false
	$OptionsMenu.visible = true
	$OptionsMenu/OptionsTabs/Appearance.grab_focus()


func _on_options_applied() -> void:
	options_updated.emit()


func _on_leave_options_menu() -> void:
	$OptionsMenu.visible = false
	$MarginContainer.visible = true
	$MarginContainer/MainMenu/OptionsButton.grab_focus()


func _on_exit_button_pressed() -> void:
	quit.emit()

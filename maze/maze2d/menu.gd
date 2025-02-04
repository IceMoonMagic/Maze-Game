class_name MazeMenu
extends Control

signal resume_maze
signal restart_maze
signal new_maze
signal options_updated
signal quit


func _ready() -> void:
	pass
	$MainMenu/NewMazeButton.grab_focus()


func on_has_maze(maze_exists: bool = true) -> void:
	$MainMenu/ResumeButton.visible = maze_exists
	$MainMenu/RestartButton.visible = maze_exists


func _on_resume_button_pressed() -> void:
	resume_maze.emit()


func _on_restart_button_pressed() -> void:
	restart_maze.emit()


func _on_new_maze_button_pressed() -> void:
	new_maze.emit()


func _on_options_button_pressed() -> void:
	$MainMenu.visible = false
	$OptionsMenu.visible = true
	$OptionsMenu/OptionsTabs/Appearance.grab_focus()


func _on_leave_options_menu() -> void:
	$OptionsMenu.visible = false
	$MainMenu.visible = true
	options_updated.emit()
	$MainMenu/OptionsButton.grab_focus()


func _on_exit_button_pressed() -> void:
	quit.emit()

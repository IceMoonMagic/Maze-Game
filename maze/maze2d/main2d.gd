extends CanvasItem

signal exit

var has_maze: bool = false
var exit_mode: Globals.ExitMode
@onready var menu: MazeMenu = %Menu
@onready var maze: Maze2D = %Maze2D
@onready var hold_to_pause: Timer = %HoldToPause


func _init(p_exit_mode: Globals.ExitMode = Globals.ExitMode.QUIT_TREE) -> void:
	exit_mode = p_exit_mode


func _ready() -> void:
	get_tree().paused = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		_on_hold_to_pause_timeout()
	if event is InputEventScreenTouch:
		if event.is_pressed():
			hold_to_pause.start()
		else:
			hold_to_pause.stop()
	if event is InputEventScreenDrag:
		hold_to_pause.stop()
	if event.is_action_pressed("Quick New"):
		_on_new_maze()
	if event.is_action_pressed("Quick Restart"):
		if has_maze:
			_on_restart_maze()


func show_maze() -> void:
	if %Menu.block_unpause:
		return
	get_tree().paused = false
	menu.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func show_menu() -> void:
	get_tree().paused = true
	menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if has_maze:
		%Menu/MarginContainer/MainMenu/ResumeButton.grab_focus()
	else:
		%Menu/MarginContainer/MainMenu/NewMazeButton.grab_focus()


func _on_new_maze() -> void:
	show_maze()
	maze.new_maze()
	has_maze = true
	menu.on_has_maze(true)


func _on_restart_maze() -> void:
	show_maze()
	maze.restart()


func _on_quit() -> void:
	match exit_mode:
		Globals.ExitMode.SIGNAL_EXIT:
			exit.emit()
		Globals.ExitMode.QUIT_TREE:
			get_tree().quit()


func _on_show_menu() -> void:
	show_menu()


func _on_resume_maze() -> void:
	show_maze()


func _on_menu_replay_path(mode: Maze2D.ReplayMode) -> void:
	show_maze()
	%Maze2D.replay_path(mode)


func _on_hold_to_pause_timeout() -> void:
	if not has_maze:
		pass
	elif menu.visible:
		show_maze()
	else:
		show_menu()

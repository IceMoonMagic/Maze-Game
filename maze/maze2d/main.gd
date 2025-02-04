extends CanvasItem

var has_maze: bool = false
@onready var menu: MazeMenu = %Menu
@onready var maze: Maze2D = %Maze2D


func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if menu.visible:
			show_maze()
		else:
			show_menu()
	if event.is_action_pressed("Quick New"):
		_on_new_maze()
	if event.is_action_pressed("Quick Restart"):
		if has_maze:
			_on_restart_maze()


func show_maze() -> void:
	#get_tree().paused = false
	menu.visible = false
	maze.visible = true
	$Maze2D/Camera2D.enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func show_menu() -> void:
	#get_tree().paused = true
	menu.visible = true
	maze.visible = false
	$Maze2D/Camera2D.enabled = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if has_maze:
		%Menu/MainMenu/ResumeButton.grab_focus()
	else:
		%Menu/MainMenu/NewMazeButton.grab_focus()


func _on_new_maze() -> void:
	show_maze()
	maze.new_maze()
	has_maze = true
	menu.on_has_maze(true)


func _on_restart_maze() -> void:
	show_maze()
	maze.restart()


func _on_options_updated() -> void:
	#if has_maze:
	#maze.apply()
	%Maze2D.update_line_options()
	#$WorldEnvironment.environment.background_mode = Environment.BG_COLOR
	RenderingServer.set_default_clear_color(MazeData.background_options.color)
	#$WorldEnvironment.environment.background_color = MazeData.background_options.color


func _on_quit() -> void:
	get_tree().quit()


func _on_show_menu() -> void:
	show_menu()


func _on_resume_maze() -> void:
	show_maze()

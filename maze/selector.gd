extends Control

signal exit

var active_scene: Node = null
var exit_mode: Globals.ExitMode
@onready var selector_menu: Control = %SelectorMenu


func _init() -> void:
	exit_mode = Globals.ExitMode.QUIT_TREE


func load_scene(path: String) -> void:
	_on_child_exit()
	selector_menu.visible = false

	var scene := load(path)
	active_scene = scene.instantiate()
	if "exit_mode" in active_scene and active_scene.has_signal("exit"):
		active_scene.exit_mode = Globals.ExitMode.SIGNAL_EXIT
		active_scene.connect("exit", _on_child_exit)
	add_child(active_scene)


func _on_child_exit() -> void:
	if active_scene == null:
		return

	active_scene.queue_free()
	active_scene = null
	selector_menu.visible = true


func _on_maze_2d_button_pressed() -> void:
	load_scene("res://maze/maze2d/main2d.tscn")


func _on_maze_3d_button_pressed() -> void:
	load_scene("res://maze/maze3d/main3d.tscn")


func _on_exit_button_pressed() -> void:
	match exit_mode:
		Globals.ExitMode.SIGNAL_EXIT:
			exit.emit()
		Globals.ExitMode.QUIT_TREE:
			get_tree().quit()

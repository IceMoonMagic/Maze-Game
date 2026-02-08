extends Control

var active_scene: Node = null
var exit_to := ""
@onready var selector_menu: Control = %SelectorMenu


func _on_child_exit() -> void:
	if active_scene == null:
		return

	active_scene.queue_free()
	active_scene = null
	selector_menu.visible = true


func _on_maze_2d_button_pressed() -> void:
	get_tree().change_scene_to_file("res://maze/maze2d/main2d.tscn")


func _on_maze_3d_button_pressed() -> void:
	get_tree().change_scene_to_file("res://maze/maze3d/main3d.tscn")


func _on_credit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://credits.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()

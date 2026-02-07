class_name SaveData
extends Resource

@export var cursor_options: LineOptionData = (
	preload("res://options/default_options/cursor_options.tres").duplicate()
)
@export var main_trail_options: LineOptionData = (
	preload("res://options/default_options/main_trail_options.tres").duplicate()
)
@export var explored_trail_options: LineOptionData = (
	preload("res://options/default_options/explored_trail_options.tres")
	. duplicate()
)
@export var wall_options: LineOptionData = (
	preload("res://options/default_options/wall_options.tres").duplicate()
)
@export var goal_options: LineOptionData = (
	preload("res://options/default_options/goal_options.tres").duplicate()
)
@export var background_options: LineOptionData = (
	preload("res://options/default_options/background_options.tres").duplicate()
)
@export var generation_options: GenerationOptionData = (
	preload("res://options/default_options/generation_options.tres").duplicate()
)
@export var maze_3d_options: Maze3DOptions = (
	preload("res://options/default_options/maze_3d_options.tres").duplicate()
)

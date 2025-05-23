class_name Maze3DOptions
extends Resource

@export var flat := false:
	set(val):
		flat = val
		emit_changed()
@export var wall_height := 2.0:
	set(val):
		wall_height = val
		emit_changed()


func equals(other: Maze3DOptions) -> bool:
	return self.flat == other.flat and self.wall_height == other.wall_height


func set_to(other: Maze3DOptions) -> Maze3DOptions:
	self.flat = other.flat
	self.wall_height = other.wall_height
	return self

class_name LineOptionData
extends Resource

@export var enabled := true:
	set(val):
		enabled = val
		emit_changed()
@export var color := Color.BLACK:
	set(val):
		color = val
		emit_changed()
@export_range(0.5, MazeData.TILE_SIZE, 0.5) var thickness := 1.0:
	set(val):
		thickness = val
		emit_changed()


func equals(other: LineOptionData) -> bool:
	return (
		self.enabled == other.enabled
		and self.color == other.color
		and self.thickness == other.thickness
	)


func set_to(other: LineOptionData) -> LineOptionData:
	self.enabled = other.enabled
	self.color = other.color
	self.thickness = other.thickness
	return self

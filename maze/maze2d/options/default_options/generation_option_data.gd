class_name GenerationOptionData
extends Resource

@export var breadth_weight := 0.0:
	set(val):
		breadth_weight = val
		emit_changed()
@export var depth_weight := 1.0:
	set(val):
		depth_weight = val
		emit_changed()
@export var random_weight := 1.0:
	set(val):
		random_weight = val
		emit_changed()
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_RESOURCE_NOT_PERSISTENT)
var weights: Array[float]:
	get:
		return [breadth_weight, depth_weight, random_weight]
	set(new_weights):
		breadth_weight = new_weights[0]
		depth_weight = new_weights[1]
		random_weight = new_weights[2]
@export var dimensions := Vector2i(0, 8)


func is_valid() -> bool:
	return (
		breadth_weight + depth_weight + random_weight != 0
		and dimensions != Vector2i.ZERO
	)


func equals(other: GenerationOptionData) -> bool:
	return (
		self.breadth_weight == other.breadth_weight
		and self.depth_weight == other.depth_weight
		and self.random_weight == other.random_weight
		and self.dimensions == other.dimensions
	)


func set_to(other: GenerationOptionData) -> GenerationOptionData:
	self.breadth_weight = other.breadth_weight
	self.depth_weight = other.depth_weight
	self.random_weight = other.random_weight
	self.dimensions = other.dimensions
	return self

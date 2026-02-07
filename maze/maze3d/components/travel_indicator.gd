class_name TravelIndicator
extends Area3D

enum Locations {
	FORWARD = 1 << 0,
	BACKWARD = 1 << 1,
	LEFT = 1 << 2,
	RIGHT = 1 << 3,
	UP_FORWARD = 1 << 4,
	UP_BACKWARD = 1 << 5,
	UP_LEFT = 1 << 6,
	UP_RIGHT = 1 << 7,
}

@export_custom(
	PROPERTY_HINT_RANGE,
	"0,10,0.1,or_greater,suffix:s,hide_slider",
	PROPERTY_USAGE_EDITOR,
)
var fade_time := 0.5
var default_color := Color.BLACK
var activated_color := Color.WHITE
var light_locations := 0
var active := false
var _fade_amount := 0.0

@onready var base_indicator: MeshInstance3D = $BaseIndicator
@onready var _material: StandardMaterial3D = base_indicator.mesh.material


func _ready() -> void:
	_place_lights()
	Globals.options_applied.connect(_update_colors)
	_update_colors()


func _process(delta: float) -> void:
	if not active or not MazeOptions.config.explored_trail_options.enabled:
		delta *= -1
	_fade_amount = clampf((_fade_amount * fade_time + delta) / fade_time, 0, 1)
	_material.albedo_color = default_color.lerp(activated_color, _fade_amount)


func _update_colors() -> void:
	default_color = MazeOptions.config.explored_trail_options.color
	default_color.a = 0
	activated_color = default_color
	activated_color.a = 1


func _place_lights() -> void:
	for child: Node in get_children():
		if "@" in child.name:
			child.queue_free()

	const OFFSET = 2.5
	for direction: Array in [
		[Locations.FORWARD, Vector3.FORWARD],
		[Locations.BACKWARD, Vector3.BACK],
		[Locations.LEFT, Vector3.LEFT],
		[Locations.RIGHT, Vector3.RIGHT],
		[Locations.UP_FORWARD, Vector3.UP + Vector3.FORWARD],
		[Locations.UP_BACKWARD, Vector3.UP + Vector3.BACK],
		[Locations.UP_LEFT, Vector3.UP + Vector3.LEFT],
		[Locations.UP_RIGHT, Vector3.UP + Vector3.RIGHT],
	]:
		if light_locations & direction[0]:
			var new_light := base_indicator.duplicate()
			new_light.position = direction[1] * OFFSET
			new_light.visible = true
			add_child(new_light)


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and body in get_overlapping_bodies():
		active = true

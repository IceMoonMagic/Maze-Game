class_name LineOptionControl
extends Control

@export var header: String = "Header":
	set(val):
		header = val
		$Label.text = header
@export var default_options := LineOptionData.new():
	set(val):
		if (
			is_instance_valid(default_options)
			and default_options.changed.is_connected(
				set_to.bind(default_options)
			)
		):
			default_options.changed.disconnect(set_to.bind(default_options))
		default_options = val
		if (
			is_instance_valid(default_options)
			and not default_options.changed.is_connected(
				set_to.bind(default_options)
			)
		):
			default_options.changed.connect(set_to.bind(default_options))
			if not is_node_ready():
				await ready
			set_to(default_options)

@onready var enabled_button: CheckButton = $Enabled/ToggleButton
@onready var enabled_reset_button: Button = $Enabled/ResetButton
@onready var color_picker: ColorPickerButton = $Color/ColorPicker
@onready var color_reset_button: Button = $Color/ResetButton
@onready var thickness_slider: HSlider = $Thickness/Slider
@onready var thickness_reset_button: Button = $Thickness/ResetButton

## Options actively in use
@onready var applied_options := LineOptionData.new().set_to(default_options)

## Modified but unsaved options
@onready var unapplied_options := LineOptionData.new().set_to(default_options)


func set_to(option_data: LineOptionData) -> void:
	enabled_button.button_pressed = option_data.enabled
	_on_enabled_button_pressed()
	color_picker.color = option_data.color
	_on_color_picker_color_changed(color_picker.color)
	thickness_slider.value = option_data.thickness


func _on_enabled_button_pressed() -> void:
	unapplied_options.enabled = enabled_button.button_pressed
	enabled_reset_button.disabled = (
		unapplied_options.enabled == default_options.enabled
	)


func _on_enabled_reset_button_pressed() -> void:
	enabled_button.button_pressed = default_options.enabled
	_on_enabled_button_pressed()


func _on_color_picker_color_changed(color: Color) -> void:
	unapplied_options.color = color
	color_reset_button.disabled = (
		unapplied_options.color == default_options.color
	)


func _on_color_reset_button_pressed() -> void:
	color_picker.color = default_options.color
	_on_color_picker_color_changed(color_picker.color)


func _on_thickness_slider_value_changed(value: float) -> void:
	unapplied_options.thickness = thickness_slider.value
	thickness_reset_button.disabled = (
		unapplied_options.thickness == default_options.thickness
	)


func _on_thickness_reset_button_pressed() -> void:
	thickness_slider.value = default_options.thickness

class_name LineOptionControl
extends Control

@onready var enabled_button: CheckButton = $Enabled/ToggleButton
@onready var enabled_reset_button: Button = $Enabled/ResetButton
@onready var color_picker: ColorPickerButton = $Color/ColorPicker
@onready var color_reset_button: Button = $Color/ResetButton
@onready var thickness_slider: HSlider = $Thickness/Slider
@onready var thickness_reset_button: Button = $Thickness/ResetButton

## Default options set in the inspector
## DO NOT MODIFY
@onready var default_options := MazeData.LineOptionData.new(
	enabled_button.button_pressed, color_picker.color, thickness_slider.value
)

## Options actively in use
@onready var applied_options := MazeData.LineOptionData.new(
	enabled_button.button_pressed, color_picker.color, thickness_slider.value
)
# ToDo: Save options to file

## Modified but unsaved options
@onready var unapplied_options := MazeData.LineOptionData.new(
	enabled_button.button_pressed, color_picker.color, thickness_slider.value
)


func set_to(option_data: MazeData.LineOptionData) -> void:
	enabled_button.button_pressed = option_data.enabled
	_on_enabled_button_pressed()
	color_picker.color = option_data.color
	_on_color_picker_popup_closed()
	thickness_slider.value = option_data.thickness
	_on_thickness_slider_drag_ended(true)


func _on_enabled_button_pressed() -> void:
	unapplied_options.enabled = enabled_button.button_pressed
	enabled_reset_button.disabled = (
		unapplied_options.enabled == default_options.enabled
	)


func _on_enabled_reset_button_pressed() -> void:
	enabled_button.button_pressed = default_options.enabled
	_on_enabled_button_pressed()


func _on_color_picker_popup_closed() -> void:
	unapplied_options.color = color_picker.color
	color_reset_button.disabled = (
		unapplied_options.color == default_options.color
	)


func _on_color_reset_button_pressed() -> void:
	color_picker.color = default_options.color
	_on_color_picker_popup_closed()


func _on_thickness_slider_drag_ended(value_changed: bool) -> void:
	if not value_changed:
		return
	unapplied_options.thickness = thickness_slider.value
	thickness_reset_button.disabled = (
		unapplied_options.thickness == default_options.thickness
	)


func _on_thickness_reset_button_pressed() -> void:
	thickness_slider.value = default_options.thickness
	_on_thickness_slider_drag_ended(true)

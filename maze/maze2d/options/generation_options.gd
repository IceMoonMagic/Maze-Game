class_name GenerationOptionControl
extends Control

@onready
var breadth_spin_box: SpinBox = $VBoxContainer/WeightsContainer/BreadthContainer/BreadthSpinBox
@onready
var depth_spin_box: SpinBox = $VBoxContainer/WeightsContainer/DepthContainer/DepthSpinBox
@onready
var random_spin_box: SpinBox = $VBoxContainer/WeightsContainer/RandomContainer/RandomSpinBox
@onready
var weights_reset_button: Button = $VBoxContainer/WeightsContainer/WeightsResetButton
@onready var preset_size_item_list: ItemList = $HBoxContainer/PresetSizeItemList
@onready
var height_spin_box: SpinBox = $HBoxContainer/DimensionContainer/WidthContainer2/HeightSpinBox
@onready
var width_spin_box: SpinBox = $HBoxContainer/DimensionContainer/WidthContainer2/WidthSpinBox
@onready
var auto_mode_slider: HSlider = $HBoxContainer/DimensionContainer/AutoModeSlider
@onready
var auto_mode_label: Label = $HBoxContainer/DimensionContainer/AutoModeLabel
@onready var auto_mode: int = floor(auto_mode_slider.value)

## Default options set in the inspector
## DO NOT MODIFY
@onready var default_options := MazeData.GenerationOptionData.new(
	breadth_spin_box.value,
	depth_spin_box.value,
	random_spin_box.value,
	Vector2i(floor(width_spin_box.value), floor(height_spin_box.value))
)

## Options actively in use
@onready var applied_options := MazeData.GenerationOptionData.new(
	breadth_spin_box.value,
	depth_spin_box.value,
	random_spin_box.value,
	Vector2i(floor(width_spin_box.value), floor(height_spin_box.value))
)
# ToDo: Save options to file

## Modified but unsaved options
@onready var unapplied_options := MazeData.GenerationOptionData.new(
	breadth_spin_box.value,
	depth_spin_box.value,
	random_spin_box.value,
	Vector2i(floor(width_spin_box.value), floor(height_spin_box.value))
)


func set_to(option_set: MazeData.GenerationOptionData) -> void:
	breadth_spin_box.value = option_set.breadth_weight
	_on_breadth_spin_box_value_changed(option_set.breadth_weight)
	depth_spin_box.value = option_set.depth_weight
	_on_depth_spin_box_value_changed(option_set.depth_weight)
	random_spin_box.value = option_set.random_weight
	_on_random_spin_box_value_changed(option_set.random_weight)
	width_spin_box.value = option_set.dimensions.x
	_on_width_spin_box_value_changed(option_set.dimensions.x)
	height_spin_box.value = option_set.dimensions.y
	_on_height_spin_box_value_changed(option_set.dimensions.y)


func update_weights_reset_button() -> void:
	weights_reset_button.disabled = (
		default_options.weights == unapplied_options.weights
	)
	update_weights_valid()


func update_weights_valid() -> void:
	var is_valid: bool = (
		(
			unapplied_options.breadth_weight
			+ unapplied_options.depth_weight
			+ unapplied_options.random_weight
		)
		!= 0
	)
	var labels: Array[Label] = [
		$VBoxContainer/WeightsContainer/BreadthContainer/BreadthLabel,
		$VBoxContainer/WeightsContainer/DepthContainer/DepthLabel,
		$VBoxContainer/WeightsContainer/RandomContainer/RandomLabel,
	]
	if is_valid:
		for label: Label in labels:
			label.remove_theme_color_override("font_color")
	else:
		for label: Label in labels:
			label.add_theme_color_override("font_color", Color("#FF0000"))


func _on_breadth_spin_box_value_changed(value: float) -> void:
	unapplied_options.breadth_weight = value
	update_weights_reset_button()


func _on_depth_spin_box_value_changed(value: float) -> void:
	unapplied_options.depth_weight = value
	update_weights_reset_button()


func _on_random_spin_box_value_changed(value: float) -> void:
	unapplied_options.random_weight = value
	update_weights_reset_button()


func update_dimensions_valid() -> void:
	var is_valid: bool = unapplied_options.dimensions != Vector2i.ZERO
	var labels: Array[Label] = [
		$HBoxContainer/DimensionContainer/LabelContainer/HeightLabel,
		$HBoxContainer/DimensionContainer/LabelContainer/WidthLabel,
	]
	if is_valid:
		for label: Label in labels:
			label.remove_theme_color_override("font_color")
	else:
		for label: Label in labels:
			label.add_theme_color_override("font_color", Color("#FF0000"))


func _on_weights_reset_button_pressed() -> void:
	breadth_spin_box.value = default_options.breadth_weight
	unapplied_options.breadth_weight = default_options.breadth_weight
	depth_spin_box.value = default_options.depth_weight
	unapplied_options.depth_weight = default_options.depth_weight
	random_spin_box.value = default_options.random_weight
	unapplied_options.random_weight = default_options.random_weight
	update_weights_reset_button()


func _on_height_spin_box_value_changed(value: float) -> void:
	unapplied_options.dimensions.y = floor(value)
	match auto_mode:
		0:  # Fit
			width_spin_box.value = 0
			_on_width_spin_box_value_changed(0)
		1:  # Square
			width_spin_box.value = value
			_on_width_spin_box_value_changed(value)
		2:  # Manual
			pass
	update_dimensions_valid()


func _on_width_spin_box_value_changed(value: float) -> void:
	unapplied_options.dimensions.x = floor(value)


func _on_auto_mode_slider_value_changed(value: float) -> void:
	auto_mode = floor(value)
	match auto_mode:
		0:
			auto_mode_label.text = "Fit"
			width_spin_box.editable = false
			_on_height_spin_box_value_changed(height_spin_box.value)
		1:
			auto_mode_label.text = "Square"
			width_spin_box.editable = false
			_on_height_spin_box_value_changed(height_spin_box.value)
		2:
			auto_mode_label.text = "Manual"
			width_spin_box.editable = true


func _on_preset_size_item_list_item_selected(index: int) -> void:
	match index:
		0:  # Small
			height_spin_box.value = 8
		1:  # Medium
			height_spin_box.value = 16
		2:  # Large
			height_spin_box.value = 32
		3:  # Custom
			height_spin_box.editable = true
			auto_mode_slider.editable = true
			_on_auto_mode_slider_value_changed(auto_mode)
			pass
	if index != 3:
		height_spin_box.editable = false
		width_spin_box.editable = false
		auto_mode_slider.editable = false
		auto_mode_slider.value = 0
		_on_auto_mode_slider_value_changed(0)
	else:
		pass

extends Node

const TILE_SIZE := 7

var config := SaveData.new()


func _ready() -> void:
	load_config_file()
	Globals.options_applied.connect(save_config_file)
	Globals.options_applied.connect(
		func() -> void:
			RenderingServer.set_default_clear_color(
				config.background_options.color
			)
	)


func load_config_file() -> Error:
	if not FileAccess.file_exists("user://config.tres"):
		return ERR_FILE_NOT_FOUND
	config = load("user://config.tres") as SaveData
	Globals.options_applied.emit()
	return OK


func save_config_file() -> Error:
	return ResourceSaver.save(config, "user://config.tres")

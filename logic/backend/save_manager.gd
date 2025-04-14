extends Node
class_name SaveManager_Test

@export var line_text : LineEdit
@export var player_color : ColorPickerButton
@export var player_stats : Label

var Ssave_key = "Antigua@Barbuda"


func _on_save_pressed() -> void:
	var config = ConfigFile.new()
	config.set_value("settings", "color", player_color.color)
	config.set_value("settings", "name", line_text.text)
	config.set_value("settings", "stats", player_stats.text)
	config.save_encrypted_pass("user://settings.cfg", Ssave_key)
	
	print("FOllowing data saved!")
	print(line_text.text)
	print(player_stats.text)
	print(player_color.color)


func _on_minus_1_pressed() -> void:
	player_stats.text = "sss"


func _on_plus_1_pressed() -> void:
	player_stats.text = "iiiii"


func _on_load_pressed() -> void:
	var config = ConfigFile.new()
	var result = config.load_encrypted_pass("user://settings.cfg", Ssave_key)
	if result == OK:
		line_text.text = config.get_value("settings", "name")
		player_color.color = config.get_value("settings", "color")
		player_stats.text = config.get_value("settings", "stats")
		print("Info Loaded!")
	else:
		printerr("Error Loading!")

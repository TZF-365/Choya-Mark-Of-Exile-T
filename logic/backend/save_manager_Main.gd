extends Node
class_name SaveManager

@export var line_text : LineEdit
@export var player_stats : Label

var Ssave_key = "Antigua@Barbuda"


func _on_save_pressed() -> void:
	var config = ConfigFile.new()
	config.set_value("settings", "name", line_text.text)
	config.set_value("settings", "stats", player_stats.text)
	config.save_encrypted_pass("user://settings.cfg", Ssave_key)
	
	print("FOllowing data saved!")
	print(line_text.text)
	print(player_stats.text)


func _on_minus_1_pressed() -> void:
	player_stats.text = "sss"


func _on_plus_1_pressed() -> void:
	player_stats.text = "iiiii"


func _on_load_pressed() -> void:
	var config = ConfigFile.new()
	var result = config.load_encrypted_pass("user://settings.cfg", Ssave_key)
	if result == OK:
		line_text.text = config.get_value("settings", "name")
		player_stats.text = config.get_value("settings", "stats")
		print("Info Loaded!")
	else:
		printerr("Error Loading!")
		
		
func save_game(player_stats: Dictionary, current_page: String) -> void:
	var config = ConfigFile.new()

	# Basic settings
	config.set_value("settings", "name", line_text.text)

	# Player stats
	for key in player_stats.keys():
		config.set_value("player_stats", key, player_stats[key])

	# Current story page
	config.set_value("story", "current_page", current_page)

	config.save_encrypted_pass("user://save_game.cfg", Ssave_key)
	print("Game Saved!")

func load_game() -> Dictionary:
	var config = ConfigFile.new()
	var result = config.load_encrypted_pass("user://save_game.cfg", Ssave_key)
	if result != OK:
		printerr("Failed to load save file!")
		return {}

	var loaded_data := {
		"name": config.get_value("settings", "name", ""),
		"color": config.get_value("settings", "color", Color.WHITE),
		"player_stats": {},
		"current_page": config.get_value("story", "current_page", "000_prologue")
	}

	for key in ["Val", "health", "mana"]: # Add all relevant stat keys here
		loaded_data["player_stats"][key] = config.get_value("player_stats", key, 0)

	print("Game Loaded!")
	return loaded_data

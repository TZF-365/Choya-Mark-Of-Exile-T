extends Node
class_name SaveManager

@export var line_text : LineEdit
@export var player_color : ColorPickerButton






func save_game(chapter_id: String, stats: Dictionary) -> void:
	var data = {
		"current_page": chapter_id,
	}

	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	if file:
		file.store_var(data)
		file.close()

func load_game() -> Dictionary:
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	if file:
		var data = file.get_var()
		file.close()
		return data
	return {}  # Return empty if load fails


func _on_save_pressed() -> void:
	var config = ConfigFile.new()
	config.set_value("settings", "color", player_color.color)
	config.set_value("settings", "name", line_text.text)
	config.save("user://settings.cfg")
	
	print("FOllowing data saved!")
	print(line_text.text)
	print(player_color.color)
	pass # Replace with function body.


func _on_minus_1_pressed() -> void:
	pass # Replace with function body.


func _on_plus_1_pressed() -> void:
	pass # Replace with function body.


func _on_load_pressed() -> void:
	var config = ConfigFile.new()
	var result = config.load("user://settings.cfg")
	pass # Replace with function body.
	
	if result == OK:
		line_text.text = config.get_value("settings", "name")
		player_color.color = config.get_value("settings", "color")
	else:
		printerr("Error Loading!")

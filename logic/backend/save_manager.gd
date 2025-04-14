<<<<<<< HEAD
<<<<<<< HEAD
extends Node

class_name SaveManager

func save_game(chapter_id: String, stats: Dictionary) -> void:
	var data = {
		"current_page": chapter_id,
	}

	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	if file:
		file.store_var(data)
		print("Data Saved!")
		file.close()

func load_game() -> Dictionary:
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	if file:
		var data = file.get_var()
		print("Data Loaded!")
		file.close()
		return data
	return {}  # Return empty if load fails
=======
extends Resource
>>>>>>> parent of 2a0b700 (Saves)
=======
extends Resource
>>>>>>> parent of 2a0b700 (Saves)

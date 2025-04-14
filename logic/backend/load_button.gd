extends Button

# Preload SaveManager and the scene
var save_manager_script = preload("res://logic/backend/save_manager.gd")
var game_scene = preload("res://scenes/game_screen.tscn")

func _pressed():
	var save_manager = save_manager_script.new()
	var save_data = save_manager.load_game()

	if save_data:
		var chapter_id = save_data.get("current_chapter", "000_prologue_1")
		var start_page = save_data.get("current_page", "000_prologue_1")
		var stats = save_data.get("stats", {})

		var scene_instance = game_scene.instantiate()

		# Ensure the scene instance is valid and set data directly
		if scene_instance:
			if scene_instance is CSLogic:  # Ensure that the scene is of type CSLogic
				scene_instance.set_game_data(chapter_id, stats, start_page)
			else:
				# Directly assign properties if not using the method
				scene_instance.current_chapter = chapter_id
				scene_instance.stat = stats
				scene_instance.start_page = start_page

			# Swap scenes
			get_tree().root.add_child(scene_instance)
			get_tree().current_scene.queue_free()
		else:
			print("Failed to instantiate the scene.")
	else:
		print("No save data found.")

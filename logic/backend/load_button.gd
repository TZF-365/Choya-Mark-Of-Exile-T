extends SaveManager

<<<<<<< HEAD
<<<<<<< Updated upstream
<<<<<<< HEAD
=======
>>>>>>> Stashed changes
# Preload SaveManager and the scene
var save_manager_script = preload("res://logic/backend/save_manager.gd")
var game_scene = preload("res://scenes/game_screen.tscn")
var current_chapter = ""
var stat = {}
var start_page = ""


=======
<<<<<<< Updated upstream
=======
>>>>>>> parent of 2a0b700 (Saves)
=======
>>>>>>> Stashed changes
var SaveManager = "res://logic/backend/save_manager.gd"

func _ready():
	pass
<<<<<<< Updated upstream
<<<<<<< HEAD
>>>>>>> parent of 2a0b700 (Saves)
=======
=======
>>>>>>> Stashed changes
>>>>>>> parent of 2a0b700 (Saves)

func _pressed():
	SaveManager.load_game()

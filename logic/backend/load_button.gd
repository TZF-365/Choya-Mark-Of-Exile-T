extends SaveManager

<<<<<<< HEAD
# Preload SaveManager and the scene
var save_manager_script = preload("res://logic/backend/save_manager.gd")
var game_scene = preload("res://scenes/game_screen.tscn")
var current_chapter = ""
var stat = {}
var start_page = ""


=======
var SaveManager = "res://logic/backend/save_manager.gd"

func _ready():
	pass
>>>>>>> parent of 2a0b700 (Saves)

func _pressed():
	SaveManager.load_game()

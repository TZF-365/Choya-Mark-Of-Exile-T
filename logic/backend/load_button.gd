extends Button

var SaveManager = "res://logic/backend/save_manager.gd"

func _ready():
	pass

func _pressed():
	SaveManager.load_game()

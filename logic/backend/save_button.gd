extends Button

var save_manager = SaveManager.new()

func _pressed():
	var data_to_save = {
		"player_name": "Kael",
		"level": 5,
		"score": 4200
	}

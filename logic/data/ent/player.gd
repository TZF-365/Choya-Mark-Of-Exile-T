extends entity

class_name Player

func _init(name: String):
	name = "Player"
	self.name = name
	self.current_vitality = 120  # Players might start with higher vitality
	self.current_stamina = 150
	body_parts["head"]["max_hp"] = 60  # Customize for the player


func level_up():
	level += 1
	current_vitality += 20
	current_stamina += 10
	print(name + " leveled up! Level: " + str(level))

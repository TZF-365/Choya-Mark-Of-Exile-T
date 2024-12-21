extends Enemy


class_name Goblin

func _init(name: String, aggression: int):
	self.name = name
	self.aggression_level = aggression
	self.current_vitalityvitality = 90  # Enemies might have lower vitality
	self.current_staminastamina = 20
	print(name + " the goblin is ready!")


func attack():
	print(name + " attacks with aggression level: " + str(aggression_level))

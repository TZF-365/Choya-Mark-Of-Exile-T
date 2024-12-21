extends entity


class_name Enemy

var aggression_level: int = 1

func _init(name: String, aggression: int):
	self.name = name
	self.aggression_level = aggression
	self.vitality = 80  # Enemies might have lower vitality
	self.stamina = 100
	self.mana = 30

# CombatInstantiator.gd
extends Node
class_name CombatInstantiator

@export var player_team: Array[BaseChar]
@export var enemy_team: Array[BaseChar]

func spawn_dummy_characters():
	var p1 = BaseChar.new()
	p1.name = "Lyaris"
	p1.skills = [
		{name = "Slash", power = 5},
		{name = "Heavy Strike", power = 10}
	]

	var e1 = BaseChar.new()
	e1.name = "Drakthyr"
	e1.skills = [
		{name = "Claw", power = 6}
	]

	player_team.append(p1)
	enemy_team.append(e1)

	return [player_team, enemy_team]

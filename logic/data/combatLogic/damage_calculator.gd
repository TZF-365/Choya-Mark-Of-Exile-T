extends Node
class_name Damage_Calculator

func calculate(skill: Dictionary, user: BaseChar, target: BaseChar) -> int:
	var base = skill.get("power", 0)
	var atk = user.strength
	var def = target.defense
	return max(1, base + atk - def)

extends Node2D

class DamageCalculator:
	static func calculate_attack(actor: BaseChar, target: BaseChar) -> float:
		var base_damage = actor.stats["strength"] * 2
		var defense_modifier = target.stats["toughness"]
		var final_damage = base_damage - defense_modifier
		
		if target.is_defending:
			final_damage -= 4  # Defending reduces damage
		if target.is_dodging and randf() < 0.5:
			return 0  # Dodge success!
		return max(final_damage, 0)  # Ensure no negative damage

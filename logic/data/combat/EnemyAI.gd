extends Node
class_name EnemyAI

# The enemy character the AI controls (you can assign this in the CombatManager)
@export var enemy: BaseChar
# The player character the AI interacts with (passed from CombatManager)
@export var player: BaseChar

# Randomly chooses an action for the enemy. You can expand this method for more sophisticated behavior.
func choose_action() -> String:
	if enemy == null:
		print("No enemy connected to enemy AI")
		return "idle"  # Safe fallback in case enemy is not assigned
	if enemy == null or player == null:
		print("No enemy or player connected to enemy AI")
		return "idle"  # Safe fallback in case enemy or player is not assigned
	else:
		var actions = ["attack", "defend", "dodge"]
		return actions[randi() % actions.size()]

# Can be expanded for more complex decision making (e.g., based on health, player behavior, etc.)
func choose_action_based_on_health() -> String:
	if enemy == null or player == null:
		print("No enemy or player connected to enemy AI")
		return "idle"  # Safe fallback in case enemy or player is not assigned
	
	# If the enemy's health is very low, be more defensive
	if enemy.health < 20:
		var actions = ["defend", "dodge"]
		return actions[randi() % actions.size()]  # Randomly choose between defend or dodge
	
	# If the enemy has lower health but not critical, mix between attacking and defending
	elif enemy.health < 50:
		if randi() % 2 == 0:
			return "defend"  # 50% chance to defend
		else:
			return "attack"  # Otherwise, attack
	
	# If the enemy has more strength than the player, prioritize attacking
	elif enemy.stats["strength"] > player.stats["strength"]:
		return "attack"  # Stronger enemy attacks
	
	# If the enemy's health is good and they are not stronger, dodge to avoid taking damage
	else:
		var actions = ["attack", "dodge"]
		return actions[randi() % actions.size()]  # Randomly choose between attack or dodge

extends Node
class_name EnemyAI

# The enemy character the AI controls (you can assign this in the CombatManager)
@export var enemy: BaseChar
# The player character the AI interacts with (passed from CombatManager)
@export var player: BaseChar

# Randomly chooses an action for the enemy. You can expand this method for more sophisticated behavior.
func choose_action_based_on_state() -> String:
	if enemy == null or player == null:
		print("No enemy or player connected to enemy AI")
		return "idle"

	var possible_actions: Array = []

	# --- Assess enemy and player health ---
	var enemy_hp_ratio = float(enemy.current_hp) / enemy.max_hp
	var player_hp_ratio = float(player.current_hp) / player.max_hp

	# --- Defensive behavior ---
	if enemy_hp_ratio < 0.2:
		# Low health -> prioritize dodge or defend
		possible_actions += ["dodge", "defend"]
	elif enemy_hp_ratio < 0.5:
		# Moderate health -> mix of defense and light attack
		possible_actions += ["light", "defend", "dodge"]

	# --- Offensive behavior ---
	if player_hp_ratio < 0.3:
		# Player is weak -> try heavier attacks or finishers if available
		if enemy.momentum >= enemy.finisher_available:
			possible_actions.append("finisher")
		else:
			possible_actions += ["heavy", "light"]
	elif player_hp_ratio < 0.6:
		possible_actions += ["light", "heavy"]

	# --- Status-based adjustments ---
	#if enemy.is_stunned or enemy.current_stamina < 2:
		# Can't perform heavy attacks -> fallback to light/dodge
	#	possible_actions = possible_actions.filter(func(a): return a != "heavy")

	if player.is_defending:
		possible_actions = possible_actions.filter(func(a): return a not in ["light", "heavy"])
		# maybe only sometimes dodge
		if randi() % 100 < 50:
			possible_actions.append("dodge")


	# --- Momentum-based prioritization ---
	if enemy.momentum > enemy.opportunity_available and not enemy.opportunity_active:
		# Open to take advantage -> consider aggressive attacks
		possible_actions.append("heavy")

	# --- Default fallback if no actions were added ---
	if possible_actions.is_empty():
		possible_actions = ["light", "defend", "dodge"]

	# Randomly select one action from the evaluated options
	var chosen_action = possible_actions[randi() % possible_actions.size()]
	print("AI chose action: %s" % chosen_action)
	return chosen_action

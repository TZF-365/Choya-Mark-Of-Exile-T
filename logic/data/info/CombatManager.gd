extends Node
class_name CombatManagerk

# Player and enemy character references
var player: BaseChar = Player_AL
@export var enemy: BaseChar

# Enemy AI controller
@export var enemy_ai: EnemyAI
var player_stats = Player_AL

# UI elements for displaying combat information
@export var combat_log: RichTextLabel
@export var player_health_label: Label
@export var enemy_health_label: Label

# UI buttons for player actions
@export var attack_button: Button
@export var defend_button: Button
@export var dodge_button: Button

# Damage-related variables
var damage: int = 0	# Temporary storage for calculated damage in a turn
var turndamage: int = 0	# Final damage applied after calculations

# Combat states
enum State { PLAYER_TURN, ENEMY_TURN, BATTLE_OVER }
var current_state: State = State.PLAYER_TURN
var current_action: String = ""	# Tracks the player's current selected action

### READY FUNCTION ###
func _ready():
	# Initialize enemy AI
	enemy_ai = EnemyAI.new()
	enemy_ai.enemy = enemy	# Assign the enemy character to the AI
	enemy_ai.player = player	# Provide a reference to the player for the AI to target

	# Update UI and start the combat log
	update_health_labels()
	add_to_log("Battle started! %s vs %s" % [player.names, enemy.names])

### ACTION RESOLUTION ###
func resolve_action(actor: BaseChar, action: String, target: BaseChar):
	"""
	Resolves a combat action (attack, defend, dodge) for the given actor.
	"""
	if action == "attack":
		damage_calc(actor, target)	# Calculate damage
		target.current_val -= turndamage	# Apply damage to the target
		target.current_val = clamp(target.current_val, 0, target.max_val)	# Ensure health stays within bounds
		add_to_log(generate_attack_description(actor, target, turndamage))	# Log the attack

	elif action == "defend":
		actor.is_defending = true	# Set the defending state
		add_to_log("%s prepares to defend!" % actor.names)

	elif action == "dodge":
		actor.is_dodging = true	# Set the dodging state
		add_to_log("%s is ready to dodge the next attack!" % actor.names)

	update_health_labels()	# Update the UI after action
	check_battle_end()	# Check if the battle is over

### DAMAGE CALCULATION ###
func damage_calc(actor: BaseChar, target: BaseChar):
	"""
	Calculates damage for an attack considering the actor's strength, 
	target's defense, and special states like defending or dodging.
	"""
	var base_damage = actor.stats["strength"] * 2.7	# Base damage based on attacker's strength
	var defense_modifier = target.stats["toughness"] * 1.24	# Defense reduces damage
	var final_damage = base_damage - defense_modifier
	turndamage = max(final_damage, 0)	# Ensure damage is not negative

	# Adjust for defending
	if target.is_defending:
		defense_modifier += 4
		turndamage = max(base_damage - defense_modifier, 1)

	# Adjust for dodging
	if target.is_dodging and randf() < 0.5:	# Example: 70% dodge chance
		turndamage = 0	# Completely avoid damage

### LOGGING ###
func add_to_log(text: String):
	"""
	Adds a message to the combat log UI.
	"""
	combat_log.add_text(text + "\n \n")

###Generating dynamic descriptions for attack###
func generate_attack_description(actor: BaseChar, target: BaseChar, damage: int) -> String:
	"""
	Generates a string description of an attack for the combat log, 
	taking into account the target's defensive or dodging actions 
	and whether they are the player or an enemy.
	"""
	var description: String = ""

	# Target is dodging
	if target.is_dodging:
		if damage > 0:
			var dodging_hit = [
				"%s tries to dodge %s's attack but is clipped, taking %d damage!",
				"%s almost evades %s's strike but takes %d damage anyway!",
				"%s leaps to avoid the blow, but %s's strike grazes them for %d damage."
			]
			description = dodging_hit[randi() % dodging_hit.size()] % [target.names, actor.names, damage]
		else:
			var dodging_miss = [
				"%s expertly dodges %s's attack, taking no damage!",
				"%s sidesteps %s's strike with ease, emerging unscathed!",
				"%s narrowly avoids %s's weapon, escaping harm!"
			]
			description = dodging_miss[randi() % dodging_miss.size()] % [target.names, actor.names]

	# Target is defending
	elif target.is_defending:
		if damage > 0:
			var defending_hit = [
				"%s braces for %s's attack, but the force breaks through for %d damage!",
				"%s holds their ground, but %s's strike lands for %d damage!",
				"%s's guard weakens as %s's blow connects for %d damage!"
			]
			description = defending_hit[randi() % defending_hit.size()] % [target.names, actor.names, damage]
		else:
			var defending_block = [
				"%s's defense holds strong, completely blocking %s's attack!",
				"%s raises their guard and nullifies %s's strike with precision!",
				"%s deflects %s's blow effortlessly, taking no damage!"
			]
			description = defending_block[randi() % defending_block.size()] % [target.names, actor.names]

	# Default (Normal attack)
	else:
		if damage > 0:
			var normal_hit = [
				"%s swings their weapon at %s, dealing %d damage!",
				"%s strikes %s with precision, inflicting %d damage!",
				"%s lands a solid blow on %s, causing %d damage!",
				"%s unleashes a powerful strike on %s, dealing %d damage!"
			]
			description = normal_hit[randi() % normal_hit.size()] % [actor.names, target.names, damage]
		else:
			var normal_miss = [
				"%s swings at %s but misses entirely!",
				"%s's attack fails to connect with %s!",
				"%s misjudges the strike, missing %s completely!"
			]
			description = normal_miss[randi() % normal_miss.size()] % [actor.names, target.names]

	return description


### HEALTH UI ###
func update_health_labels():
	"""
	Updates the UI to reflect current health of player and enemy.
	"""
	player_health_label.text = "Player Val: %d" % player.current_val
	enemy_health_label.text = "Enemy Val: %d" % enemy.current_val

### END OF BATTLE ###
func check_battle_end():
	"""
	Checks if either the player or the enemy has been defeated.
	"""
	if player.current_val <= 0:
		add_to_log("%s has been defeated! Game Over." % player.names)
		current_state = State.BATTLE_OVER
	elif enemy.current_val <= 0:
		add_to_log("%s has been defeated! You Win!" % enemy.names)
		current_state = State.BATTLE_OVER

### TURN PROCESSING ###
func process_turn(action: String):
	"""
	Processes the current turn, resolving the player's action and then
	transitioning to the enemy's turn if the battle continues.
	"""
	if current_state == State.BATTLE_OVER:
		return

	if current_state == State.PLAYER_TURN:
		resolve_action(player, action, enemy)
		if current_state != State.BATTLE_OVER:
			current_state = State.ENEMY_TURN
			enemy_turn()

func enemy_turn():
	"""
	Handles the enemy's turn by allowing the AI to choose and resolve an action.
	"""
	if current_state == State.BATTLE_OVER:
		return

	var action = enemy_ai.choose_action_based_on_health()	# AI determines its action
	add_to_log("Enemy action chosen: %s" % action)
	resolve_action(enemy, action, player)

	if current_state != State.BATTLE_OVER:
		current_state = State.PLAYER_TURN

### BUTTON HANDLERS ###
func _on_attack_pressed():
	"""
	Triggered when the attack button is pressed. Executes the player's attack action.
	"""
	current_action = "attack"
	process_turn(current_action)

func _on_defend_pressed():
	"""
	Triggered when the defend button is pressed. Executes the player's defend action.
	"""
	current_action = "defend"
	process_turn(current_action)

func _on_dodge_pressed():
	"""
	Triggered when the dodge button is pressed. Executes the player's dodge action.
	"""
	current_action = "dodge"
	process_turn(current_action)

###FOR THE MAIN COMBAT MANAGER###
func _on_action_pressed() -> void:
	"""
	Triggered when the attack button is pressed. Executes the player's attack action.
	"""
	current_action = "attack"
	process_turn(current_action)

func _on_inspect_pressed() -> void:
	"""
	Triggered when the defend button is pressed. Executes the player's defend action.
	"""
	current_action = "defend"
	process_turn(current_action)

func _on_move_pressed() -> void:
	"""
	Triggered when the dodge button is pressed. Executes the player's dodge action.
	"""
	current_action = "dodge"
	process_turn(current_action)

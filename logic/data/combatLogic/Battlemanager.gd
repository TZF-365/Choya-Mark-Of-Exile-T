extends Node
class_name CombatManager
#m
# Player and enemy character references
var player: BaseChar = Player_AL
@export var enemy: BaseChar

# Enemy AI controller
@export var enemy_ai: EnemyAI
var player_stats = Player_AL

var turn_log: String = ""  # Buffer for this turn's combat text
var is_first_turn := true




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
	
	player.equip_skill_from_file("res://logic/data/resources/Skills/fireball.tres")
	combat_log.bbcode_enabled = true  # Ensure BBCode is enabled

	combat_log.clear()  # Clear previous content

	# Update UI and start the combat log
	update_health_labels()
	add_to_turn_log("Battle started! %s vs %s \n \n" % [player.display_name, enemy.display_name])

func resolve_action(actor: BaseChar, action: String, target: BaseChar):
	"""
	Resolves a combat action (light_attack, heavy_attack, defend, dodge, or skill usage) for the given actor.
	"""
	var log_entry = ""  # Temporary buffer for the current action's log entry

	if action == "light_attack":
		damage = damage_calc(actor, target, "light")
		target.current_hp -= damage
		target.current_hp = clamp(target.current_hp, 0, target.max_hp)
		log_entry = generate_attack_description(actor, target, damage)
	elif action == "heavy_attack":
		damage = damage_calc(actor, target, "heavy")
		target.current_hp -= damage
		target.current_hp = clamp(target.current_hp, 0, target.max_hp)
		log_entry = generate_attack_description(actor, target, damage)
	elif action == "attack":
		damage = damage_calc(actor, target, "normal")
		target.current_hp -= damage
		target.current_hp = clamp(target.current_hp, 0, target.max_hp)
		log_entry = generate_attack_description(actor, target, damage)
	elif action == "defend":
		actor.is_defending = true
		log_entry = "%s prepares to defend!" % actor.display_name
	elif action == "dodge":
		actor.is_dodging = true
		log_entry = "%s is ready to dodge the next attack!" % actor.display_name
	elif action == "use_skill":
		if actor.skills.has("Fireball"):
			actor.use_skill("Fireball", target)
			log_entry = "%s uses Fireball on %s!" % [actor.display_name, target.display_name]

	add_to_turn_log(log_entry)  # Add the log entry to the turn log
	update_health_labels()  # Update the UI after action
	check_battle_end()  # Check if the battle is over


	
func add_to_turn_log(text: String):
	"""
	Adds text to the turn log buffer. Logs are collected and displayed at the end of the turn.
	"""
	turn_log += text + " "  # Append the text with a trailing space for readability


func finalize_turn_log():
	"""
	Appends the collected turn log to the combat log and clears the buffer for the next turn.
	Formats the text into a single paragraph for readability.
	"""
	if turn_log.strip_edges() != "":
		combat_log.append_text("[b] [/b]\n%s\n\n" % turn_log.strip_edges())
		turn_log = ""  # Reset the buffer for the next turn




### DAMAGE CALCULATION ###
func damage_calc(actor: BaseChar, target: BaseChar, attack_type: String) -> int:
	"""
	Calculates damage for an attack considering the actor's strength, 
	target's defense, special states like defending or dodging, 
	and the type of attack (light, heavy, normal).
	"""
	# Base damage calculation based on actor's strength
	var base_damage = actor.stats["strength"] * 2.7	# Base damage based on attacker's strength
	
	# Adjust base damage based on the attack type (light, heavy, normal)
	match attack_type:
		"light":
			base_damage *= 0.75  # Light attacks are weaker but faster
		"heavy":
			base_damage *= 1.5  # Heavy attacks are stronger but slower
		"normal":
			pass  # No scaling for normal attacks

	# Defense modifier based on the target's toughness
	var defense_modifier = target.stats["toughness"] * 1.24	# Target's toughness reduces damage

	# Apply defending state: increase defense by a percentage
	if target.is_defending:
		var defense_boost = 0.2  # 20% increase to toughness when defending
		defense_modifier *= (1 + defense_boost)

	# Apply dodging state: reduce incoming damage by a percentage chance
	if target.is_dodging:
		var dodge_chance = 0.5  # 50% chance to dodge
		if randf() < dodge_chance:
			# Reduce damage by 30% if dodging (customizable)
			base_damage *= 0.7
			# Log dodging
			add_to_turn_log("%s dodges the attack, reducing damage!" % target.display_name)

	# Final damage after applying defense modifier
	var final_damage = base_damage - defense_modifier
	# Ensure the final damage is not negative
	final_damage = max(final_damage, 0)

	# Return the final damage as an integer
	return int(final_damage)


###Generating dynamic descriptions for attack###
@warning_ignore("shadowed_variable")
func generate_attack_description(actor: BaseChar, target: BaseChar, damage: int) -> String:
	var description: String = ""

	# Target is dodging
	if target.is_dodging:
		if damage > 0:
			var dodging_hit = [
				"%s tries to dodge %s but gets clipped for %d damage.",
				"%s gets grazed while dodging — %d damage.",
				"%s almost evades %s's strike but takes %d damage anyway!",
				"%s stumbles mid-dodge and takes %d from %s.",
				"%s nearly evades %s, but still takes %d."
			]
			var choice := randi() % dodging_hit.size()
			match choice:
				0, 2, 4:
					description = dodging_hit[choice] % [target.display_name, actor.display_name, damage]
				1:
					description = dodging_hit[choice] % [target.display_name, damage]
				3:
					description = dodging_hit[choice] % [target.display_name, damage, actor.display_name]
		else:
			var dodging_miss = [
				"%s expertly dodges %s's attack, taking no damage!",
				"%s sidesteps the strike.",
				"%s sidesteps %s's strike with ease, emerging unscathed!",
				"%s dodges %s cleanly.",
				"%s evades the attack."
			]
			var choice := randi() % dodging_miss.size()
			match choice:
				0, 2, 3:
					description = dodging_miss[choice] % [target.display_name, actor.display_name]
				1, 4:
					description = dodging_miss[choice] % [target.display_name]

	# Target is defending
	elif target.is_defending:
		if damage > 0:
			var defending_hit = [
				"%s braces for %s's attack, but the force breaks through for %d damage!",
				"%s guards but takes %d from %s.",
				"%s holds their ground, but %s's strike lands for %d damage!",
				"%s's guard falters — %d damage.",
				"%s's guard weakens as %s's blow connects for %d damage!",
				"%s braces, still takes %d."
			]
			var choice := randi() % defending_hit.size()
			match choice:
				0, 2, 4:
					description = defending_hit[choice] % [target.display_name, actor.display_name, damage]
				1:
					description = defending_hit[choice] % [target.display_name, damage, actor.display_name]
				3, 5:
					description = defending_hit[choice] % [target.display_name, damage]
		else:
			var defending_block = [
				"%s blocks %s completely.",
				"%s deflects the attack.",
				"%s raises their guard and nullifies %s's strike with precision!",
				"%s's guard holds firm.",
				"%s deflects %s's blow effortlessly, taking no damage!",
				"%s shrugs off the blow."
			]
			var choice := randi() % defending_block.size()
			match choice:
				0, 1, 3, 5:
					description = defending_block[choice] % [target.display_name, actor.display_name]
				2, 4, 6:
					description = defending_block[choice] % [target.display_name]

	# Default (Normal attack)
	else:
		if damage > 0:
			var normal_hit = [
				"%s hits %s for %d.",
				"%s strikes — %d damage to %s.",
				"%s lands a hit on %s (%d).",
				"%s wounds %s for %d.",
				"%s attacks %s, dealing %d."
			]
			var choice := randi() % normal_hit.size()
			match choice:
				0, 3, 4:
					description = normal_hit[choice] % [actor.display_name, target.display_name, damage]
				1:
					description = normal_hit[choice] % [actor.display_name, damage, target.display_name]
				2:
					description = normal_hit[choice] % [actor.display_name, target.display_name, damage]
		else:
			var normal_miss = [
				"%s swings at %s but misses entirely!",
				"%s's attack fails to connect with %s!",
				"%s's attack whiffs.",
				"%s misjudges the strike, missing %s completely!",
				"%s dodges just in time.",
				"%s misses %s."
			]
			var choice := randi() % normal_miss.size()
			match choice:
				0, 1, 3, 6:
					description = normal_miss[choice] % [actor.display_name, target.display_name]
				2, 4:
					description = normal_miss[choice] % [actor.display_name]
				5:
					description = normal_miss[choice] % [target.display_name]

	return description



### HEALTH UI ###
func update_health_labels():
	"""
	Updates the UI to reflect current health of player and enemy.
	"""
	player_health_label.text = "Player Val: %d" % player.val
	enemy_health_label.text = "Enemy Val: %d" % enemy.val

### END OF BATTLE ###
func check_battle_end():
	"""
	Checks if either the player or the enemy has been defeated.
	"""
	if player.current_hp <= 0:
		add_to_turn_log("\n \n%s has been defeated! Game Over." % player.display_name)
		current_state = State.BATTLE_OVER
	elif enemy.current_hp <= 0:
		add_to_turn_log("\n \n %s has been defeated! You Win!" % enemy.display_name)
		current_state = State.BATTLE_OVER

### TURN PROCESSING ###
func process_turn(action: String):
	if current_state == State.BATTLE_OVER:
		return

	if current_state == State.PLAYER_TURN:
		add_to_turn_log("[b]Player Turn:[/b]")  # Label for player's turn
		trigger_event()  # Check for special events
		resolve_action(player, action, enemy)
		if current_state != State.BATTLE_OVER:
			current_state = State.ENEMY_TURN
			enemy_turn()

		# Finalize and display the combined log for this whole turn
		player.update_val()
		enemy.update_val()
		finalize_turn_log()


func enemy_turn():
	"""
	Handles the enemy's turn by allowing the AI to choose and resolve an action.
	"""
	if current_state == State.BATTLE_OVER:
		return

	add_to_turn_log("[b]Enemy Turn:[/b]")  # Label for enemy's turn
	var action = enemy_ai.choose_action_based_on_health()
	add_to_turn_log("Enemy action chosen: %s" % action)
	resolve_action(enemy, action, player)

	if current_state != State.BATTLE_OVER:
		current_state = State.PLAYER_TURN
		

		
		
# Add a boolean variable to track if the event has occurred
var event_triggered: bool = false

func trigger_event():
	# Check if the event hasn't been triggered and the conditions are met
	if not event_triggered and player.current_hp < 50 and randf() < 1.0:
		var sound_effect = preload("res://assets/Music/I_Will_Not_Let_You.mp3")
		AudioManager.play_sound_effect_with_dynamic_fade(sound_effect, 3.0)
		add_to_turn_log("RAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA I WILL NOT LET YOU DESTROY MY WORRRRLLLLDDD... \n \n")
		player.stats["strength"] += 5
		event_triggered = true  # Mark the event as triggered so it doesn't activate again



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
	
	process_turn(current_action)


func _on_move_pressed() -> void:
	"""
	Triggered when the dodge button is pressed. Executes the player's dodge action.
	"""
	current_action = "dodge"
	process_turn(current_action)
	
func _on_tactical_overview_pressed() -> void:
	player.use_skill("Fireball", enemy)
	resolve_action(player, "use_skill", enemy)
	pass # Replace with function body.


func _on_items_pressed() -> void:
	current_action = "heavy"
	pass # Replace with function body.

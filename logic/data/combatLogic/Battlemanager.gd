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

#tweens for transition effects
@onready var health_tween = create_tween()  # Adjust path if needed
@onready var fade_tween = create_tween()  # Tween for fade-in effect


# UI elements for displaying combat information
@export var combat_log: RichTextLabel

#player and opponent val tracker
@export var player_health_label: Label
@export var enemy_health_label: Label
@export var enemy_name_label: Label

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




# Load technique resource
var cleave_technique = load("res://logic/data/resources/Techniques/cleave.tres") as Technique_
var stab_technique = load("res://logic/data/resources/Techniques/quick_jab.tres") as Technique_

# Equip to player or enemy



### READY FUNCTION ###
func _ready():
	var technique = choose_technique(player, enemy, "light")

		
	# Create the tween instance for hp animation
	update_health_labels()
	
	#preload weapon	armor
	var dagger = preload("res://logic/data/resources/Items/weapons/bronze_dagger.tres")
	var sword = preload("res://logic/data/resources/Items/weapons/glass_rapier.tres")
	
	player.equip_weapon(sword, "main_hand")
	var iron_chest = load("res://logic/data/resources/Items/armors/Leather_Curass.tres") as ArmorResource
	player.equip_armor("chest", iron_chest)

	enemy.techniques.append(stab_technique)
	enemy.equip_armor("chest", iron_chest)
	enemy.equip_weapon(dagger, "main_hand")
	
	# Initialize enemy AI
	enemy_ai = EnemyAI.new()
	enemy_ai.enemy = enemy	# Assign the enemy character to the AI
	enemy_ai.player = player	# Provide a reference to the player for the AI to target
	
	player.equip_skill_from_file("res://logic/data/resources/Skills/fireball.tres") #equips skill to character
	combat_log.bbcode_enabled = true  # Ensure BBCode is enabled
	combat_log.clear()  # Clear previous content

	# Add starting battle log and display it immediately
	add_to_turn_log("Battle started! %s vs %s \n \n" % [player.display_name, enemy.display_name])
	finalize_turn_log()  # <- this pushes the log buffer into the RichTextLabel

	# Start fade-in effect for combat log
# Start fade-in effect for combat log
	combat_log.modulate.a = 0.0
	fade_tween = create_tween()
	fade_tween.tween_property(combat_log, "modulate:a", 1.0, 1.0)
	
	update_health_labels()

func _process(_delta):
	# Update the displayed values as the tweens progress
	player_health_label.text = "Player Val: %d" % int(displayed_player_val)
	enemy_health_label.text = "Enemy Val: %d" % int(displayed_enemy_val)
	enemy_name_label.text = enemy.display_name


func resolve_action(actor: BaseChar, action: String, target: BaseChar):
	"""
	Resolves a combat action (light_attack, heavy_attack, defend, dodge, or skill usage) for the given actor.
	"""
	var log_entry = ""  # Temporary buffer for the current action's log entry
	var attack_type = "light" if action == "light" else "heavy" if action == "heavy" else "normal"
	
	var chosen_technique = choose_technique(actor, target, attack_type)
	if chosen_technique != null:
		log_entry += "%s uses %s! " % [actor.display_name, chosen_technique.name]
		print("Chosen technique: %s by %s" % [chosen_technique.name, actor.display_name])  # <-- THIS
		damage = damage_calc(actor, target, attack_type, chosen_technique)
		
	else:
		damage = damage_calc(actor, target, attack_type)
		print("No technique used by %s. Using standard damage." % actor.display_name)
		

	target.current_hp -= damage
	target.current_hp = clamp(target.current_hp, 0, target.max_hp)
	log_entry += generate_attack_description(actor, target, damage)
	update_health_labels()

	if action == "defend":
		actor.is_defending = true
		log_entry = "%s prepares to defend!" % actor.display_name
	if action == "dodge":
		actor.is_dodging = true
		log_entry = "%s is becoming evasive!" % actor.display_name
	if action == "use_skill":
		if actor.skills.has("Fireball"):
			actor.use_skill("Fireball", target)
			log_entry = "%s uses Fireball on %s!" % [actor.display_name, target.display_name]

	add_to_turn_log(log_entry)  # Add the log entry to the turn log
	update_health_labels()  # Update the UI after action
	check_battle_end()  # Check if the battle is over
	reset_combat_states(player)
	reset_combat_states(enemy)


func choose_technique(actor: BaseChar, target: BaseChar, attack_type: String) -> Technique_:
	for technique in actor.techniques:
		if technique.attack_type != attack_type:
			continue
		if technique.stance_required != "" and technique.stance_required != actor.current_stance:
			continue
		if technique.requires_momentum > 0 and actor.momentum < technique.requires_momentum:
			continue
		if technique.trigger_condition != null and technique.trigger_condition.is_valid():
			if not technique.trigger_condition.call(actor, target):
				continue
		return technique
	print("No valid technique found for %s (attack type: %s). Techniques checked: %d" % [actor.display_name, attack_type, actor.techniques.size()])
	return null


func reset_combat_states(char: BaseChar):
	char.is_defending = false
	char.is_dodging = false


##LOGGING
func add_to_turn_log(text: String):
	"""
	Adds text to the turn log buffer. Logs are collected and displayed at the end of the turn.
	"""
	turn_log += text + " "  # Append the text with a trailing space for readability

	# Start scroll animation when new text is added


func finalize_turn_log():
	"""
	Appends the collected turn log to the combat log and clears the buffer for the next turn.
	Formats the text into a single paragraph for readability.
	"""
	if turn_log.strip_edges() != "":
		combat_log.append_text("%s\n\n" % turn_log.strip_edges())

		turn_log = ""  # Reset the buffer for the next turn
	update_health_labels()  # <-- This ensures health is updated once, at the end of both turns


func damage_calc(actor: BaseChar, target: BaseChar, attack_type: String, technique: Technique = null) -> int:
	var attack_power = actor.stats["strength"] * 2.7 + actor.get_weapon_power()
	var multiplier = get_final_multiplier(actor, target, attack_type, technique)
	var base_damage = attack_power * multiplier
	print("🔸 Attack Power: %.2f, Multiplier: %.2f, Base Damage: %.2f" % [attack_power, multiplier, base_damage])

	# Armor damage reduction
	var armor_reduction = apply_armor_reduction(target, attack_power)
	print("🛡️ Armor Reduction: %.2f" % armor_reduction)
	base_damage -= armor_reduction
	print("🔻 Damage After Armor: %.2f" % base_damage)

	# Defensive effects
	if target.is_defending:
		base_damage *= 0.8
		add_to_turn_log("%s braces for impact, reducing damage!" % target.display_name)
	elif target.is_dodging and randf() < 0.5:
		base_damage *= 0.7
		add_to_turn_log("%s dodges the attack, reducing damage!" % target.display_name)

	# Subtract toughness
	var defense_modifier = target.stats["toughness"] * 1.74
	var final_damage = max(int(base_damage - defense_modifier), 0)
	print("🧱 Toughness Reduction: %.2f, Final Damage: %d" % [defense_modifier, final_damage])

	# Reduce armor durability based on 10% of attack power
	update_armor_durability(target, attack_power)

	return final_damage



func apply_armor_reduction(target: BaseChar, attack_power: float) -> float:
	if target.armor_slots == null:
		return 2.0

	var total_reduction := 0.0
	var broken_armor_slots := []

	for armor_piece in target.armor_slots.values():
		if armor_piece is ItemResource:
			if armor_piece.broken:
				continue

			var percent_reduction: float = armor_piece.damage_reduction
			var durability_factor: float = float(armor_piece.durability) / armor_piece.max_durability
			var scaled_reduction: float = percent_reduction * durability_factor
			var reduced_amount: float = attack_power * scaled_reduction

			total_reduction += reduced_amount

			add_to_turn_log("%s's %s reduces damage by %.2f (%.0f%% x %.0f%%)!" % [
				target.display_name,
				armor_piece.slot_name,
				reduced_amount,
				percent_reduction * 100,
				durability_factor * 100
			])

			if durability_factor < 0.303:
				if randi() % 100 < 50:
					add_to_turn_log("%s's %s breaks due to low durability!" % [target.display_name, armor_piece.name])
					armor_piece.broken = true
					broken_armor_slots.append(armor_piece.slot_name)
					print("🧪 Break check — durability factor:", durability_factor)

	# Clean up broken armor
	for slot_name in broken_armor_slots:
		target.armor_slots.erase(slot_name)

	return total_reduction






func update_armor_durability(target: BaseChar, attack_power: float) -> void:
	if target.armor_slots == null:
		return

	for slot in target.armor_slots.values():
		if slot is ArmorResource:
			var durability_loss = int(attack_power * 0.1)
			slot.durability = max(slot.durability - durability_loss, 0)

			if slot.durability < (slot.max_durability * 0.3):
				if randf() < 0.25:
					add_to_turn_log("%s's %s breaks under the stress unexpectidly!" % [target.display_name, slot.slot_name])
					slot.broken = true  # Use this flag in other checks
					slot.durability = 0
					


func get_final_multiplier(actor: BaseChar, target: BaseChar, attack_type: String, technique: Technique = null) -> float:
	var multiplier = 1.0

	# Technique bonus
	if technique != null:
		multiplier = technique.power_multiplier(actor)

	# Stance multiplier
	match attack_type:
		"light":
			multiplier *= 0.82
		"heavy":
			multiplier *= 1.0
		"special":
			multiplier *= 1.2

	# Momentum bonus

	# Low HP boost
	if actor.current_hp < 0.25:
		multiplier += actor.bonus_when_low_hp

	return multiplier


	
	




###Generating dynamic descriptions for attack###
@warning_ignore("shadowed_variable")
func generate_attack_description(actor: BaseChar, target: BaseChar, damage: int) -> String:
	var description: String = ""

	# Target is dodging
	if target.is_dodging:
		if damage > 0:
			var dodging_hit = [
				"%s tries to dodge %s but gets clipped for %d damage.",
				"%s gets hit while dodging — %d damage.",
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
				0, 2, 4:
					description = defending_block[choice] % [target.display_name, actor.display_name]
				1, 3, 5:
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
				"%s misses"
			]
			var choice := randi() % normal_miss.size()
			match choice:
				0, 1, 3:
					description = normal_miss[choice] % [actor.display_name, target.display_name]
				2, 4:
					description = normal_miss[choice] % [actor.display_name]
				5:
					description = normal_miss[choice] % [target.display_name]

	return description


### HEALTH UI ###

var displayed_player_val := 0.01
var displayed_enemy_val := 0.01

func update_health_labels():
	if health_tween != null:
		health_tween.kill()  # Optional: stop any current tweens if you want to reset
	# Tween player val over 0.5 seconds
	health_tween = create_tween()
	# Tween player val
	health_tween.tween_property(self, "displayed_player_val", player.val, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	# Tween enemy val
	health_tween.tween_property(self, "displayed_enemy_val", enemy.val, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

func set_displayed_player_val(val):
	displayed_player_val = val
	player_health_label.text = "Player Val: %d" % int(val)

func set_displayed_enemy_val(val):
	displayed_enemy_val = val
	enemy_health_label.text = "Enemy Val: %d" % int(val)


var next_CHAPTER_ON_WIN
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
		add_to_turn_log("  ")  # Label for player's turn
		trigger_event()  # Check for special events
		resolve_action(player, action, enemy)
		if current_state != State.BATTLE_OVER:
			current_state = State.ENEMY_TURN
			enemy_turn()

		# Finalize and display the combined log for this whole turn
		player.update_val()
		enemy.update_val()
		print(turn_log) 
		finalize_turn_log()

#ENEMY TURN
func enemy_turn():
	"""
	Handles the enemy's turn by allowing the AI to choose and resolve an action.
	"""
	if current_state == State.BATTLE_OVER:
		return

	add_to_turn_log("  ")  # Label for enemy's turn
	var action = enemy_ai.choose_action_based_on_health()
	resolve_action(enemy, action, player)

	if current_state != State.BATTLE_OVER:
		current_state = State.PLAYER_TURN
# Add a boolean variable to track if the event has occurred
var event_triggered: bool = false


###EVENTS
func trigger_event():
	# Check if the event hasn't been triggered and the conditions are met
	if not event_triggered and player.current_hp < 50 and randf() < 1.0:
		var sound_effect = preload("res://assets/Music/I_Will_Not_Let_You.mp3")
		AudioManager.play_sound_effect_with_dynamic_fade(sound_effect, 3.0)
		add_to_turn_log("RAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA I WILL NOT LET YOU DESTROY MY WORRRRLLLLDDD... \n \n")
		player.stats["strength"] += 3
		event_triggered = true  # Mark the event as triggered so it doesn't activate again




func _on_light_attack_pressed() -> void:
	current_action = "light"
	process_turn(current_action)


func _on_heavy_attack_pressed() -> void:
	current_action = "heavy"
	process_turn(current_action)


func _on_use_skill_pressed() -> void:
	current_action = "use_skill"
	process_turn(current_action)
	

func _on_defend_pressed() -> void:
	"""
	Triggered when the defend button is pressed. Executes the player's defend action.
	"""
	current_action = "defend"
	process_turn(current_action)
	

func _on_dodge_pressed() -> void:
	"""
	Triggered when the dodge button is pressed. Executes the player's dodge action.
	"""
	current_action = "dodge"
	process_turn(current_action)

	
func _on_turn_pressed() -> void:
	"""
	Triggered when the attack button is pressed. Executes the player's attack action.
	"""
	current_action = "attack"
	process_turn(current_action)
	


func _on_magic_pressed() -> void:
	pass # Replace with function body.

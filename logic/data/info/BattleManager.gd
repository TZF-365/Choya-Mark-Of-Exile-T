extends Node
class_name CombatManager
#m
# Player and enemy character references
var player: BaseChar = Player_AL
@export var enemy: BaseChar
const CombatTextManager = preload("res:///CombatTextManager.gd")


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
	
func init_battle(enemy_scene_path: String, ai_type: String):
	var enemy_instance = preload(enemy_scene_path).instantiate()
	add_child(enemy_instance)
	enemy = enemy_instance
	enemy_ai = load("res://ai/%s.gd" % ai_type).new()
	enemy_ai.enemy = enemy
	# Position, weather, allies, etc.
	current_state = State.PLAYER_TURN
	update_ui()
	add_to_log("A wild %s appears!" % enemy.names)

func update_ui():
	print("UI Updated")

func is_critical_hit(attacker, target) -> bool:
	return attacker.crit_chance > randf()

var awareness = observer.awareness
var threshold = 0.7
key = "weakness" if awareness >= threshold else "pattern"


### ACTION RESOLUTION ###
func resolve_action(actor: BaseChar, action: String, target: BaseChar):
	"""
	Resolves a combat action (attack, defend, dodge) for the given actor.
	"""
	if action == "attack":
		damage_calc(actor, target)
		target.current_val -= turndamage
		add_to_log(generate_combat_paragraph(actor, "attack", target, turndamage))


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



func generate_combat_paragraph(actor: BaseChar, action: String, target: BaseChar, damage: int) -> String:
	var weapon_name = actor.equipped_weapon.name  # or however you track it
	var category = action  # e.g. "attack", "defend", "dodge", "observe"
	var key = ""
	if action == "attack":
		if damage <= 0:
			key = "normal_miss"
		elif is_critical_hit(actor):
			key = "critical"
		else:
			key = "normal_hit"
	elif action == "defend":
		key = "broken" if target.is_defending and damage > 0 else "success"
	elif action == "dodge":
		key = "success" if damage == 0 else "partial"
	elif action == "observe":
		# randomly choose between "pattern" or "weakness" based on awareness
		key = "weakness" if some_awareness_metric >= threshold else "pattern"
	# Fetch a template
	var template = CombatTextManager.get_random_template(category, key)
	# Replace placeholders
	template = template.replace("{actor}", actor.names)
	template = template.replace("{target}", target.names)
	template = template.replace("{weapon}", weapon_name)
	template = template.replace("{damage}", str(damage))
	return template




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
	if current_state == State.BATTLE_OVER:
		if player.current_val > 0:
			get_tree().change_scene_to_file(story_path_on_win)
		else:
			get_tree().change_scene_to_file(story_path_on_lose)
	

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

extends Node
class_name CombatManager

@export var player_node: PackedScene
@export var enemy_node: PackedScene
@export var enemy_ai: EnemyAI  # The AI for the enemy

@export var player: BaseChar
@export var enemy: BaseChar

@export var combat_log: RichTextLabel
@export var player_health_label: Label
@export var enemy_health_label: Label

@export var attack_button: Button
@export var defend_button: Button
@export var dodge_button: Button

var damage: int = 0  # Default to 0 if no attack
var turndamage = 0 

enum State { PLAYER_TURN, ENEMY_TURN, BATTLE_OVER }
var current_state: State = State.PLAYER_TURN
var current_action: String = ""

func _ready():
	# Initialize enemy AI
	
	enemy_ai = EnemyAI.new()
	enemy_ai.enemy = enemy  # Set the enemy for AI to control
	enemy_ai.player = player  # Pass the player reference to the enemy AI
	
	update_health_labels()
	add_to_log("Battle started! %s vs %s" % [player.name, enemy.name])
	update_health_labels()


func resolve_action(actor: BaseChar, action: String, target: BaseChar):
	# Initialize damage variable

	if action == "attack":
		# Calculate and apply damage once
		damage_calc(actor, target)
		damage = turndamage
		target.health -= turndamage
		target.health = clamp(target.health, 0, target.max_health)
		
		# Log the attack
		add_to_log(generate_attack_description(actor, target, damage))

	elif action == "defend":
		# Mark the actor as defending
		actor.is_defending = true
		add_to_log("%s prepares to defend!" % actor.name)

	elif action == "dodge":
		# Mark the actor as dodging
		actor.is_dodging = true
		add_to_log("%s is ready to dodge the next attack!" % actor.name)

	# Reset defensive/dodge status after action is resolved
	update_health_labels()




func damage_calc(actor: BaseChar, target: BaseChar):
	var base_damage = actor.stats["strength"] * 3
	var defense_modifier = target.stats["toughness"]
	var final_damage = base_damage - defense_modifier
	turndamage = final_damage
		
	# If the target is defending, reduce the damage more
	if actor.is_defending:
		defense_modifier += 4  # Example: Defending reduces damage by 4
		print(defense_modifier)
		turndamage = final_damage
	# Check if the target is dodging, and determine dodge chance
	if actor.is_dodging and randf() < 1:  # Example: 50% chance to dodge
		final_damage = 2
		print(final_damage)
		turndamage = final_damage

	# Ensure damage is not negative
	print(final_damage)
	
	


func add_to_log(text: String):
	combat_log.add_text(text + "\n \n")


func generate_attack_description(actor: BaseChar, target: BaseChar, damage: int) -> String:
	return "%s swings their weapon at %s, dealing %d damage." % [actor.name, target.name, damage]


func update_health_labels():
	player_health_label.text = "Player Health: %d" % player.health
	enemy_health_label.text = "Enemy Health: %d" % enemy.health


func check_battle_end():
	if player.health <= 0:
		add_to_log("%s has been defeated! Game Over." % player.name)
		current_state = State.BATTLE_OVER
	elif enemy.health <= 0:
		add_to_log("%s has been defeated! You Win!" % enemy.name)
		current_state = State.BATTLE_OVER


func process_turn(action: String):
	if current_state == State.BATTLE_OVER:
		return
		
	if current_state == State.PLAYER_TURN:
		resolve_action(player, action, enemy)
		if current_state != State.BATTLE_OVER:
			current_state = State.ENEMY_TURN
			enemy_turn()
	elif current_state == State.ENEMY_TURN:
		enemy_turn()


func enemy_turn():
	if current_state == State.BATTLE_OVER:
		return
	
	# Let the enemy AI choose its action
	var action = enemy_ai.choose_action_based_on_health()
	add_to_log("Enemy action chosen: %s" % action)  # Log the action for debugging
	resolve_action(enemy, action, player)
	enemy.is_defending = true
	enemy.is_dodging = false
	if current_state != State.BATTLE_OVER:
		current_state = State.PLAYER_TURN


func choose_enemy_action() -> String:
	# Randomly choose between "attack", "defend", and "dodge"
	var actions = ["attack", "defend", "dodge"]
	return actions[randi() % actions.size()]


# Button signal handlers
func _on_attack_pressed():
	current_action = "attack"
	process_turn(current_action)

func _on_defend_pressed():
	current_action = "defend"
	process_turn(current_action)

func _on_dodge_pressed():
	current_action = "dodge"
	process_turn(current_action)

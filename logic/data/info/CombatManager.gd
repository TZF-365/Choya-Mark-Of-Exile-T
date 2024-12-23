extends Node
class_name CombatManager

@export var player_node: PackedScene
@export var enemy_node: PackedScene

var player: BaseChar
var enemy: BaseChar

@export var combat_log: RichTextLabel
@export var player_health_label: Label
@export var enemy_health_label: Label

@export var attack_button: Button
@export var defend_button: Button
@export var dodge_button: Button

enum State { PLAYER_TURN, ENEMY_TURN, BATTLE_OVER }
var current_state: State = State.PLAYER_TURN
var current_action: String = ""

func _ready():
	# Initialize player and enemy
	player = player_node.instantiate() as BaseChar
	enemy = enemy_node.instantiate() as BaseChar
	
	# Add player and enemy to the scene
	add_child(player)
	add_child(enemy)
	
	update_health_labels()
	add_to_log("Battle started! %s vs %s" % [player.name, enemy.name])
	
	# Connect button signals
	_on_attack_pressed()
	_on_defend_pressed()
	_on_dodge_pressed()

func resolve_action(actor: BaseChar, action: String, target: BaseChar):
	if action == "attack":
		var damage = damage_calc(actor, target)
		target.health -= damage
		add_to_log(generate_attack_description(actor, target, damage))
	elif action == "defend":
		actor.is_defending = true
		add_to_log("%s prepares to defend!" % actor.name)
	elif action == "dodge":
		actor.is_dodging = true
		add_to_log("%s is ready to dodge the next attack!" % actor.name)
	
	# Update health labels and check for battle end
	update_health_labels()
	check_battle_end()

func damage_calc(actor: BaseChar, target: BaseChar) -> int:
	var base_damage = actor.stats["strength"] * 2
	var defense_modifier = target.stats["endurance"]
	
	# Reduce damage if the target is defending
	if target.is_defending:
		defense_modifier *= 2
	
	# Check if the target successfully dodges
	if target.is_dodging and randi() % 100 < target.stats["agility"]:
		add_to_log("%s dodged the attack!" % target.name)
		return 0

	return max(base_damage - defense_modifier, 0)

func add_to_log(text: String):
	combat_log.add_text(text + "\n")

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
		player.is_defending = false
		player.is_dodging = false
		if current_state != State.BATTLE_OVER:
			current_state = State.ENEMY_TURN
			enemy_turn()
	elif current_state == State.ENEMY_TURN:
		enemy_turn()

func enemy_turn():
	if current_state == State.BATTLE_OVER:
		return
	
	# Simple AI for enemy actions
	var action = choose_enemy_action()
	resolve_action(enemy, action, player)
	enemy.is_defending = false
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

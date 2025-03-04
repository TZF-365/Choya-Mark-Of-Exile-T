extends Node


# References to participants in combat
@export var player: Node
@export var enemy: Node

# Track whose turn it is
var is_player_turn = true

func start_combat():
	print("Combat has started!")
	# Initialize combatants (e.g., reset stats, statuses)
	player.call("reset_combat_stats")
	enemy.call("reset_combat_stats")
	combat_loop()

func combat_loop():
	if is_player_turn:
		print("Player's Turn")
		# Wait for player input to take action
	else:
		print("Enemy's Turn")
		enemy_turn()

func player_action(action_type: String, target: Node, body_part: String = "torso"):
	match action_type:
		"attack":
			player.call("attack", target, body_part)
		"defend":
			player.call("defend")
		"use_skill":
			player.call("use_skill", target)

	# End player's turn
	is_player_turn = false
	combat_loop()

func enemy_turn():
	# Basic AI for enemy
	enemy.call("attack", player, "torso")
	is_player_turn = true
	combat_loop()

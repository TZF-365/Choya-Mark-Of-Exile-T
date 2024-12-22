extends Node


@export var player_node: NodePath
@export var enemy_node: NodePath

var is_player_turn = true

func _ready():
	display_turn_options()

func display_turn_options():
	if is_player_turn:
		# Show action buttons for the player
		pass
	else:
		execute_enemy_turn()

func execute_action(action: String):
	match action:
		"attack":
			get_node(enemy_node).take_damage(10)
		"block":
			# Implement blocking logic
			pass
	end_turn()

func end_turn():
	is_player_turn = !is_player_turn
	display_turn_options()

func execute_enemy_turn():
	# Simple AI: Always attack
	get_node(player_node).take_damage(10)
	end_turn()

extends Node
class_name CombatInstantiator

@export var enemy_list: Array[BaseChar] = []  # Manually assignable enemy list
@export var enemy_ai_list: Array[EnemyAI] = []  # Optional: assign AI profiles

var player_team: Array[BaseChar] = []
var enemy_team: Array[BaseChar] = []

func _ready():
	setup_combat()

func setup_combat():
	var player = Player_AL  # Automatically pull in current player data (assumed to be BaseChar)
	if player == null:
		push_error("Player_AL is null! Cannot begin combat.")
		return

	player_team.append(player)

	# Ensure enemies were set up before entering combat
	if enemy_list.is_empty():
		push_error("Enemy list is empty! Assign enemies before entering combat scene.")
		return

	for enemy in enemy_list:
		enemy_team.append(enemy)

	print("Combat setup complete:")
	print("Player team: ", player_team)
	print("Enemy team: ", enemy_team)

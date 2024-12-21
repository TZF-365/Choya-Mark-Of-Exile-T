extends Node2D

class_name Character

@export var max_health: int = 100
@export var stamina: int = 50
var current_health: int
var action_points: int

func initialize_player():
	current_health = max_health
	action_points = stamina

func take_damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	queue_free()

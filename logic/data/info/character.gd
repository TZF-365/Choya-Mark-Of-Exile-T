extends Resource #use Resource for easy instancing
class_name BaseChar

@export var name: String = "Unnamed"

@export var max_health: int = 100
@export var current_health: int = 20
@export var stamina: int = 50
@export var mana: int = 30 
@export var action_points: int = 4
@export var val: int


@export var dstats: Dictionary = {
	"strength": 2,
	"dextarity": 4,
	"endurance": 5,
	"perception": 2, 
}


@export var skills: Dictionary = {
	"swordmanship": 0, 
	"dodging": 0,
	"bareknuckle": 0
}


@export var equipment: Dictionary = {
	"left_hand": null,
	"right_hand": null,
	"shirt": null, 
	"pants": null, 
	"helm": null
}


@export var body_part_hp: Dictionary = {
	"head": 30, 
	"left_hand": 50,
	"right_hand": 50,
	"chest": 50, 
	"left_leg": 40, 
	"right_leg": 40
	
}


func initialize():
	current_health = max_health
	action_points = stamina
	val = current_health
	print("Initialize called.")


func take_damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		die()


func die():
	pass

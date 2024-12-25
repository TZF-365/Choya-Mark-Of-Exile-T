extends Node2D #use Resource for easy instancing
class_name BaseChar

@export var health: int = 100
@export var names: String = "Unname"
@export var max_health: int = 100
@export var current_health: int = 20
@export var stamina: int = 50
@export var mana: int = 30 
@export var action_points: int = 4
@export var val: int

# New properties
@export var is_defending: bool = false
@export var is_dodging: bool = false


@export var stats: Dictionary = {
	"strength": 2,
	"dextarity": 4,
	"endurance": 5,
	"toughness": 10,
	"perception": 2, 
	"agility": 5
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


@export var story_var: Dictionary = {
	"won": false,
	"lost": false, 
	"wincondition1": false,
	"wincondition2": false,
	"wincondition3": false,
	"wincondition4": false,
	"playeruninjured": false,
	"playerinjured": false,
	"playerbadlyinjured": false,
}

extends Node
class_name BaseChar

# General properties
@export var names: String = "Unnamed"
@export var max_val: int = 100
@export var current_val: int = 100
@export var stamina: int = 50
@export var max_stamina: int = 50
@export var mana: int = 30
@export var max_mana: int = 30
@export var action_points: int = 4
@export var max_action_points: int = 4
@export var is_alive: bool = true
@export var max_part_val: int = 1
@export var body_part_amount: int = 1
@export var damage_percentage: int = 1

# Combat status
@export var is_defending: bool = false
@export var is_dodging: bool = false
@export var status_effects: Array = [] # Holds active status effects (e.g., "Injured", "Crippled")
@export var combat_state: String = "Idle" # Current combat state ("Idle", "Attacking", etc.)

# Attributes and stats
@export var stats: Dictionary = {
	"strength": 2,
	"dexterity": 4,
	"endurance": 5,
	"toughness": 10,
	"perception": 2,
	"agility": 5
}

# Skills
@export var skills: Dictionary = {
	"swordsmanship": 0,
	"dodging": 0,
	"bare_knuckle": 0
}

# Equipment
@export var equipment: Dictionary = {
	"left_hand": null,
	"right_hand": null,
	"armor": null,
	"helmet": null
}

# Body part VAL (for location-based damage)
@export var body_part_val: Dictionary = {
	"head": 30,
	"left_hand": 50,
	"right_hand": 50,
	"chest": 50,
	"left_leg": 40,
	"right_leg": 40
}

# Story-related variables
@export var story_var: Dictionary = {
	"won": false,
	"lost": false,
	"win_condition1": false,
	"player_uninjured": false,
	"player_injured": false,
	"player_badly_injured": false
}

# Combat actions
func take_damage(amount: int, body_part: String):
	if body_part in body_part_val:
		# Reduce body part VAL
		body_part_val[body_part] -= amount
		if body_part_val[body_part] < 0:
			body_part_val[body_part] = 0
		
		# Reduce overall VAL
		current_val -= amount
		if current_val < 0:
			current_val = 0
			is_alive = false
		
		# Apply status effects based on percentage of body part damage
		apply_status_effects(body_part)
	else:
		current_val -= amount
		if current_val < 0:
			current_val = 0
			is_alive = false

func apply_status_effects(body_part: String):
	if body_part in body_part_val:
		max_part_val = body_part_val[body_part] + body_part_amount  # Calculate original max body part VAL
		damage_percentage = (max_part_val - body_part_val[body_part]) / max_part_val * 100

		# Example effects based on damage percentage
		if damage_percentage > 50:
			match body_part:
				"head":
					add_status_effect("Concussion")
				"left_hand", "right_hand":
					add_status_effect("Hand Crippled")
				"left_leg", "right_leg":
					add_status_effect("Limp")
				"chest":
					add_status_effect("Internal Injury")
		
		elif damage_percentage > 20:
			add_status_effect("Bruised " + body_part)

func heal(amount: int):
	current_val = min(current_val + amount, max_val)

func use_stamina(amount: int) -> bool:
	if stamina >= amount:
		stamina -= amount
		return true
	return false

func restore_stamina(amount: int):
	stamina = min(stamina + amount, max_stamina)

func use_mana(amount: int) -> bool:
	if mana >= amount:
		mana -= amount
		return true
	return false

func restore_mana(amount: int):
	mana = min(mana + amount, max_mana)

# Status effects
func add_status_effect(effect: String):
	if effect not in status_effects:
		status_effects.append(effect)

func remove_status_effect(effect: String):
	if effect in status_effects:
		status_effects.erase(effect)

# Turn-end cleanup
func end_turn():
	is_defending = false
	is_dodging = false

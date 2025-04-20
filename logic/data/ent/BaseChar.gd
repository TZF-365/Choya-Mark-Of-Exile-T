extends Node
class_name Base_Charm

# General properties
@export var display_name: String = "Lycarus"
@export var val: int = 10
@export var max_hp: int = 100
@export var current_hp: int = 100
var current_val = current_hp
@export var stamina: int = 50
@export var max_stamina: int = 50
@export var mana: int = 30
@export var max_mana: int = 30
@export var action_points: int = 4
@export var max_action_points: int = 4
@export var max_part_val: int = 1
@export var body_part_amount: int = 1
@export var damage_percentage: int = 1
@export var coins: int = 100

var team_id: int = -1
var turn_order: Array[BaseChar]

@export var skills: Dictionary = {}  # Initialize as an empty Dictionary

func equip_skill_from_file(path: String):
	var loaded = load(path)
	if loaded is SkillResource:
		var skill = loaded as SkillResource
		print("Loaded skill name: %s" % skill.name)

		skills[skill.name] = skill
	else:
		print("Failed to load skill or invalid type at: ", path)

		
# Function to add skill to the character's skills dictionary
func add_skill(skill: SkillResource):
	if skill.name not in skills:
		skills[skill.name] = skill
		print(display_name + " has learned " + skill.name)


func take_damage(amount: int, source: BaseChar = null):
	# Apply the damage
	current_hp -= amount
	current_hp = clamp(current_hp, 0, max_hp)
	print("%s takes %d damage from %s" % [self.name, amount, source.name])
	update_val()
	
	# Optional: Print or log who caused the damage
	if source:
		print("%s took %d damage from %s!" % [self.name, amount, source.name])
	else:
		print("%s took %d damage!" % [self.name, amount])
		

func use_skill(skill_name: String, target: BaseChar):
	if skills.has(skill_name):
		var skill = skills[skill_name]
		if skill.effect_type == "damage":
			target.take_damage(skill.effect_value, self)
			print("%s uses %s on %s for %d damage!" % [self.name, skill.name, target.name, skill.effect_value])
	else:
		print("Skill not found!")



# ✅ Correct
func is_alive() -> bool:
	return current_hp > 0


# Combat status
@export var is_defending: bool = false
@export var is_dodging: bool = false
@export var status_effects: Array = [] # Holds active status effects (e.g., "Injured", "Crippled")
@export var combat_state: String = "Idle" # Current combat state ("Idle", "Attacking", etc.)

# Attributes and stats
@export var stats: Dictionary = {
	"strength": 6,
	"dexterity": 4,
	"endurance": 5,
	"toughness": 8,
	"perception": 5,
	"agility": 5
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



# Function to update `val` based on current health
func update_val():
	if max_hp == 0:  # Avoid division by zero in case max_hp is set to 0
		val = 0
	else:
		# Calculate the percentage of health and scale to 0-10
		val = int((current_hp / float(max_hp)) * 10)
		# Clamp the value to ensure it stays within the 0-10 range
		val = clamp(val, 0, 10)
		
# Custom setter for `current_hp` to auto-update `val`
func set_current_hp(new_hp: int):
	current_hp = clamp(new_hp, 0, max_hp)  # Ensure HP stays within bounds
	update_val()  # Update `val` whenever HP changes

# Custom setter for `max_hp` to auto-update `val`
func set_max_hp(new_max_hp: int):
	max_hp = max(new_max_hp, 1)  # Ensure max_hp is not zero
	update_val()  # Recalculate `val` when max_hp changes


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
	current_hp += amount
	current_hp = min(current_hp, max_hp)  # Prevent exceeding max_hp
	update_val()
	
func show_val():
	print("Current health (scaled to 0-10): %d" % val)

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
	
	
func get_stat(stat_name: String) -> int:
	return stats.get(stat_name, 0)

func apply_damage(amount: int):
	current_hp = max(current_hp - amount, 0)

extends Node
class_name Base_Charm

# General properties
@export var display_name: String = "Lycarus"
@export var val: float = 10.00
@export var max_hp: int = 100
@export var current_hp: int = 100
var current_val = current_hp
@export var stamina: int = current_stamina 
@export var current_stamina: int = 50
@export var max_stamina: int = 50
@export var endurance: float = 25
@export var max_endurance: float = 25
@export var mana: int = 30
@export var max_mana: int = 30
@export var action_points: int = 4
@export var max_action_points: int = 4
@export var max_part_val: int = 1
@export var body_part_amount: int = 1
@export var damage_percentage: int = 1
@export var coins: int = 100
@export var momentum: int = 15
@export var max_momentum: int = 100
@export var current_stance: String = "neutral"

#momentum stats
@export var opportunity_available: int = 30
@export var finisher_available: int = 55

@export var opportunity_active: bool = false
@export var finisher_active: bool = false

var opportunity_used_this_turn: bool = false
var finisher_used_this_turn: bool = false


var team_id: int = -1
var turn_order: Array[BaseChar]

@export var skills: Dictionary = {}  # Initialize as an empty Dictionary
@export var techniques: Array[Technique_] = []
@export var known_techniques: Array[Resource] = []

var current_action: String = ""




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
	"main_hand": null,
	"off_hand": null,
	"accessory": []
}

var armor_slots := {
	"head": null,
	"chest": null,
	"legs": null,
	"arms": null,
	"shield": null
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


func get_weapon_power() -> float:
	var weapon = get_equipped_weapon("main_hand")
	if weapon and weapon is WeaponResource:
		return weapon.weapon_power(self)
	return 2.0



func take_damage(amount: int, source: BaseChar = null):
	var total_damage = amount

	# Check if the character has armor equipped
	var reduction := get_damage_reduction_from_hit()
	total_damage -= total_damage * reduction

	# Check if momentum allows bypassing armor
	if momentum >= 100:  # Example: if momentum exceeds a threshold, armor is bypassed
		print("%s's momentum bypasses armor!" % display_name)
		total_damage = amount * 1.5  # Double the damage as an example

	# Apply the final damage
	current_hp -= total_damage
	current_hp = clamp(current_hp, 0, max_hp)

	print("%s takes %d damage after armor reduction!" % [self.name, total_damage])
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
		
func choose_technique(actor: BaseChar, target: BaseChar, attack_type: String) -> Technique_:
	for technique in actor.techniques:
		if technique.attack_type == attack_type:
			if technique.stance_required == "" or technique.stance_required == actor.current_stance:
				if technique.requires_momentum <= actor.momentum:
					if technique.trigger_condition == null or technique.trigger_condition.call(actor, target):
						return technique
	return null
	
	
func equip_weapon(weapon: ItemResource, slot: String = "main_hand") -> bool:
	if weapon == null or not weapon.is_weapon:
		print("Cannot equip: Not a valid weapon.")
		return false

	if not equipment.has(slot):
		print("Invalid equipment slot: ", slot)
		return false

	# Check two-handed logic
	if weapon.is_two_handed:
		equipment["main_hand"] = weapon
		equipment["off_hand"] = weapon
		print("%s equipped %s in both hands." % [display_name, weapon.name])
	else:
		equipment[slot] = weapon
		print("%s equipped %s in %s." % [display_name, weapon.name, slot])

	return true

func unequip_weapon(slot: String) -> bool:
	if not equipment.has(slot) or equipment[slot] == null:
		print("No weapon to unequip in %s." % slot)
		return false

	var removed_weapon = equipment[slot]
	equipment[slot] = null

	# Handle two-handed cleanup
	if removed_weapon.is_two_handed:
		if slot == "main_hand":
			equipment["off_hand"] = null
		elif slot == "off_hand":
			equipment["main_hand"] = null

	print("%s unequipped %s from %s." % [display_name, removed_weapon.name, slot])
	return true



func get_equipped_weapon(slot: String = "main_hand") -> ItemResource:
	if equipment.has(slot):
		return equipment[slot]
	return null

#ARMOR 
func equip_armor(slot: String, armor: ArmorResource) -> void:
	if not armor:
		push_error("Tried to equip null armor.")
		return
	if not armor.is_armor:
		push_error("This item is not valid armor.")
		return

	armor_slots[slot] = armor
	print("✅ Equipped '%s' to %s slot." % [armor.name, slot])

func get_armor_for_hit() -> ArmorResource:
	# Simplified: Assume "chest" is always hit. You can randomize or base this on technique later.
	return armor_slots.get("chest", null)


func resolve_hit_location() -> String:
	var roll = randf()
	if roll < 0.4:
		return "chest"
	elif roll < 0.65:
		return "arms"
	elif roll < 0.8:
		return "legs"
	elif roll < 0.9:
		return "head"
	else:
		return "shield"

func get_damage_reduction_from_hit() -> float:
	var hit_location = resolve_hit_location()
	var armor_piece = armor_slots[hit_location]

	if armor_piece == null:
		print("No armor at hit location.")
		return 0.0

	# Check for durability
	var durability_factor = armor_piece.durability / armor_piece.max_durability
	var reduction = armor_piece.damagec_reduction * durability_factor
	print("Armor durability factor:", durability_factor, "Raw reduction:", armor_piece.damage_reduction, "Final reduction:", reduction)

	# Bypass & Break Logic
	if durability_factor < 0.3:
		var break_chance = 0.0
		if durability_factor <= 0.2:
			break_chance = 0.10
		elif durability_factor <= 0.25:
			break_chance = 0.05
		elif durability_factor <= 0.3:
			break_chance = 0.02

		if randf() < break_chance:
			print("%s's %s armor broke!" % [display_name, hit_location])
			armor_slots[hit_location] = null
			return 0.0

		# Bypass chance could be implemented similarly
		var bypass_chance = break_chance * 1.5
		if randf() < bypass_chance:
			print("The attack bypassed %s's %s armor!" % [display_name, hit_location])
			return 0.0
	print("Reduction is", reduction)
	return reduction


# ✅ Correct
func is_alive() -> bool:
	return current_hp > 0
	

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
				"left_hand", "main_hand":
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

# SkillResource.gd
extends Resource
class_name SkillResource

enum SkillCategory {
	PASSIVE_NON_COMBAT,
	PASSIVE_COMBAT,
	ACTIVE_COMBAT
}

# Skill properties
@export var name: String = "Unknown Skill"
@export var description: String = "Description of the skill"
@export var cost: int = 10  # Cost in action points, stamina, mana, etc.
@export var cooldown: int = 0  # Turns until skill is available again
@export var level: int = 1  # Current skill level
@export var max_level: int = 5  # Maximum level for this skill
@export var is_active: bool = false  # If the skill is active or not
@export var xp: int = 0
@export var xp_required_for_next_level: int = 100

# Skill effects, can be customized based on the type of skill
@export var effect_type: String = "damage"  # "damage", "heal", "buff", etc.
@export var effect_value: int = 0  # The value of the effect (damage amount, heal amount, etc.)

func gain_xp(amount: int):
	xp += amount
	if xp >= xp_required_for_next_level:
		level_up()


func level_up():
	if level < max_level:
		level += 1
		xp = 0
		xp_required_for_next_level *= 1.5  # Increase XP requirement for the next level
		print(name + " leveled up to level " + str(level))
	else:
		print(name + " is already at max level!")



func cast(caster: BaseChar, target: BaseChar) -> void:
	var damage = caster.stats["intelligence"] * 3 - target.stats["toughness"] * 0.5
	damage = max(damage, 0)
	target.current_hp -= damage
	print("%s casts Fireball on %s for %d damage" % [caster.display_name, target.display_name, damage])



# Constructor can be omitted as we are using the export variables

# Passive skills - Increase stats or proficiency
func increase_health(caster: BaseChar):
	caster.max_hp += 10  # Example effect
	print(caster.name + " has gained more health!")
	
func increase_stamina(caster: BaseChar):
	caster.max_stamina += 5  # Example effect
	print(caster.name + " has gained more stamina!")

func increase_sword_proficiency(caster: BaseChar):
	caster.weapon_proficiency["sword"] += 1
	print(caster.name + " is now better at using a sword!")
	
	
# Passive combat skills - Modify standard attacks
func sword_cleave(caster: BaseChar, target: BaseChar):
	if caster.weapon_proficiency["sword"] >= 3:  # Example condition
		var damage = 40  # Cleave damage
		target.current_hp -= damage
		print(caster.name + " performs a sword cleave on " + target.name + " for " + str(damage) + " damage!")

# Active combat skills - Trigger magic or physical attacks
func fireball(caster: BaseChar, target: BaseChar):
	var damage = 30 + caster.stats["intelligence"] * 1.5
	print("Fireball damage calculation: " + str(damage))
	
	# Apply the damage
	target.current_hp -= damage
	target.current_hp = clamp(target.current_hp, 0, target.max_hp)  # Ensure health stays within bounds
	
	print(target.name + " takes " + str(damage) + " damage from Fireball!")
	print(target.name + "'s current HP: " + str(target.current_hp))


# Active combat skill with condition (e.g., parry first to disarm)
func disarm(caster: BaseChar, target: BaseChar):
	if caster.has_parried_last_turn:
		target.is_disarmed = true
		print(target.name + " has been disarmed!")
	else:
		print(caster.name + " failed to disarm because they did not parry!")

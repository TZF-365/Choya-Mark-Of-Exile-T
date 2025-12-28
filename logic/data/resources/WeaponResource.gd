@tool
extends ItemResource
class_name WeaponResource

@export var critical_chance: float
@export var reach: float
@export var parry_bonus: float
@export var weapon_traits: Array
@export var Weapon_str: float #weapon power actually
@export var weapon_type: String = "sword"  # This is required

func get_weapon_power(character: BaseChar) -> float:
	var weapon = character.get_equipped_weapon("main_hand")
	if not weapon:
		return 2.0
	
	var weapon_type = weapon.weapon_type
	var base_power = WeaponProficiencyDB.WEAPON_PROFICIENCIES[weapon_type]["base_power"]
	
	# Find character skill for this weapon
	var skill: SkillResource = null
	for s in character.skills:
		if s.data_name == weapon_type:
			skill = s
			break
	
	if not skill:
		# No skill learned yet
		skill = SkillResource.new()
		skill.data_name = weapon_type
		character.skills.append(skill)
	
	var proficiency_multiplier = WeaponProficiencyDB.get_proficiency_multiplier(weapon_type, skill.level)
	var power = base_power * proficiency_multiplier
	return power

# In WeaponResource
func weapon_power(character: Base_Charm) -> float:
	var total_power = 0.0
	var slots = ["main_hand", "off_hand"]

	for slot in slots:
		var weapon = character.equipment.get(slot)
		if weapon and weapon.is_weapon:
			var max_weapon_power = self.get_weapon_power(character)
			var durability_percent = clamp(float(weapon.durability) / float(weapon.max_durability), 0.0, 1.0)
			var scaling_factor = 0.2 + 0.8 * durability_percent
			var actual_power = max_weapon_power * scaling_factor
			
			# Reduce off-hand power
			if slot == "off_hand":
				actual_power *= 0.65  # 65% of its normal power

			total_power += actual_power
			print(total_power, "IS WEAPON POWER BTW")
			
	return round(total_power * 100) / 100.0  # 2 decimal places

	
var MATERIAL_MULTIPLIERS := {
	"iron": 1.3,
	"steel": 1.47,
	"wood": 0.75,
	"glass": 0.4,
	"bronze": 1.1,
	"leather": 0.6
}

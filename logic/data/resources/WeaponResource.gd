@tool
extends ItemResource
class_name WeaponResource

@export var critical_chance: float
@export var reach: float
@export var parry_bonus: float
@export var weapon_traits: Array


# In WeaponResource
func weapon_power(character: Base_Charm) -> float:  # Make sure character is of type Base_Charm
	var total_power = 0.0
	var slots = ["main_hand", "off_hand"]

	for slot in slots:
		var weapon = character.equipment.get(slot)  # Access 'equipment' here
		if weapon and weapon.is_weapon:
			var weight = weapon.weight
			var material_multiplier = MATERIAL_MULTIPLIERS.get(weapon.material, 1.2)
			var max_weapon_power = material_multiplier * weight * 4.0
			var durability_percent = clamp(float(weapon.durability) / float(weapon.max_durability), 0.0, 1.0)
			var scaling_factor = 0.2 + 0.8 * durability_percent
			var actual_power = max_weapon_power * scaling_factor
			total_power += actual_power
			print(total_power, "IS WEPON POWER BTW")
	return round(total_power * 100) / 100.0  # 2 decimal places
	
	
var MATERIAL_MULTIPLIERS := {
	"iron": 1.3,
	"steel": 1.47,
	"wood": 0.75,
	"glass": 0.4,
	"bronze": 1.1,
	"leather": 0.6
}

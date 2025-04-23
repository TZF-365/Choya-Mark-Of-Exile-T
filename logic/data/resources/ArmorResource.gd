@tool
extends ItemResource
class_name ArmorResource

@export var armor_class: int
@export var slot_name: String = ""
@export var encumbrance: float
@export var movement_penalty: float
@export var armor_type: String
@export var damage_reduction: float  # Percentage damage reduction (e.g., 0.25 for 25% damage reduction)
@export var critical_hit_prevention: bool = true
@export var armor_traits: Array
@export var is_armor: bool = false # Marks if the item is a weapon
@export var broken: bool = false  # ← Add this line

var base_reduction = damage_reduction # Base damage reduction value

	# Function to get the current damage reduction based on durability
func get_damage_reduction() -> float:
		# Armor reduction is affected by durability, lower durability means less reduction
	var durability_factor = durability / max_durability
	return base_reduction * durability_factor

	# Function to reduce the durability of the armor when it takes damage
func reduce_durability(damage_taken: float) -> void:
	# Reduce durability based on the damage received
	var durability_loss = damage_taken * 0.1 # Armor loses 10% of the damage taken
	durability = max(durability - durability_loss, 0.0) # Ensure durability doesn't go below 0
	# Optionally log or handle when armor breaks
	if durability == 0:
		print("Armor is broken and no longer provides protection!")

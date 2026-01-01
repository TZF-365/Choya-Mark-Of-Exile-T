@tool
extends ItemResource
class_name ArmorResource

@export var armor_class: int

# Only allow valid slot names
@export_enum("head", "chest", "arms", "legs", "shield")
var slot_name: String = "chest"
var valid_slots := ["head", "chest", "arms", "legs", "shield"]

@export var encumbrance: float
@export var movement_penalty: float
@export var armor_type: String
@export var damage_reduction: float = 0.1  # Base reduction, e.g., 0.25 = 25%

@export var critical_hit_prevention: bool = false
@export var armor_traits: Array = [] # e.g., ["heavy armor", "steel"]
@export var is_armor: bool = true
@export var broken: bool = false

var base_reduction = damage_reduction

# Setter to enforce valid slot names
func set_slot_name(value: String) -> void:
	if value in valid_slots:
		slot_name = value
	else:
		push_warning("Invalid slot name: %s. Must be one of %s" % [value, valid_slots])
		slot_name = "head" # default fallback

# Get damage reduction scaled by durability
func get_damage_reduction() -> float:
	var durability_factor = durability / max_durability
	return base_reduction * durability_factor

# Reduce durability based on damage received
func reduce_durability(damage_taken: float) -> void:
	var durability_loss = damage_taken * 0.1 # loses 10% of incoming damage
	durability = max(durability - durability_loss, 0.0)
	if durability == 0:
		print("%s armor is broken!" % slot_name)
		broken = true

@tool
extends Resource
class_name ItemResource

# Basic Item Attributes
@export var id: String
@export var name: String
@export var description: String
@export var type: String
@export var uses: int
@export var weight: float
@export var cost: int
@export var durability: int
@export var throwable: bool
@export var fragility: String
@export var material: String
@export var comfort: int

# Tags
@export var tags: Array = []

# Combat-related Data
@export var combat_data: Dictionary = {
	"attack_power": 0,
	"skills_linked": [],
	"custom_use_text": "",
	"attack_flavor_text": ""
}

# Resistance values
@export var resistances: Dictionary = {
	"slash": 0,
	"blunt": 0,
	"pierce": 0,
	"force": 0,
	"magic": 0
}

# Damage type
@export var damage_type: String = "slash"

# Ownership Data
@export var ownership: Dictionary = {
	"made_by": "",
	"owned_by": "",
	"is_stolen": false,
	"is_equipped": false
}

# Conditions
@export var conditions: Dictionary = {
	"destruction": {"min_durability": 0},
	"disarming": {"min_durability": 10}
}

# Materials the item is made of
@export var materials_made_from: Array = []

# Stackable item or not
@export var stackable: bool = false

# Item Effects (e.g., buffs or debuffs)
@export var item_effects: Array = []
@export var value: int = 1 # Monetary or trade value of the item
@export var rarity: String = "Common" # Rarity tier (e.g., "Common", "Rare", "Legendary")

### **Ownership and Acquisition**
@export var item_owner: String = "Null" # Current owner of the item (e.g., player, NPC)
@export var is_stolen: bool = false # Indicates if the item is marked as stolen
@export var acquisition_method: String = "Found" # How the item was acquired (e.g., "Bought", "Looted", "Gifted")

### **Usage and Effects**
@export var is_usable: bool = false # Whether the item can be actively used
@export var use_effects: Dictionary = {} # Dictionary of effects when used (e.g., { "heal": 20, "mana_restore": 10 })

### **Quest Item Variables**
@export var is_quest_item: bool = false # Marks if the item is a quest item
@export var quest_id: int = 0 # Links the item to a specific quest
@export var quest_progress: Dictionary = {} # Tracks progress-related variables for the quest

### **Weapon Variables**
@export var is_weapon: bool = false # Marks if the item is a weapon
@export var damage_types: Dictionary = { "physical": 0, "magical": 0, "fire": 0 } # Types and values of damage dealt
@export var weapon_class: String = "None" # Type of weapon (e.g., "Sword", "Bow", "Staff")
@export var attack_speed: float = 1.0 # Speed of attack
@export var is_two_handed: bool = false # If the weapon requires two hands

### **Miscellaneous Variables**
@export var max_stack: int = 1 # Maximum stack size (if stackable)
@export var interactable_with_world: bool = true # If the item can interact with the world (e.g., tree branches)

### **Dynamic or Procedural Variables**
@export var is_dynamic: bool = false # Indicates if the item is procedurally generated
@export var generation_seed: int = 0 # Seed for procedural generation


func calculate_weapon_durability(weapon: ItemResource) -> int:
	var material_durability = get_material_durability(weapon.material)
	var weight_factor = weapon.weight / 10
	var durability = material_durability * weight_factor
	return durability


func get_material_durability(material: String) -> int:
	match material:
		"iron": return 80
		"steel": return 100
		"wood": return 50
		"glass": return 30
		"bronze": return 60
		"leather": return 40
		_ : return 50  # Default durability

func calculate_attack_power(weapon: ItemResource) -> int:
	var material_power = get_material_attack_power(weapon.material)
	var weight_factor = weapon.weight / 2
	var durability_factor = weapon.durability / 100
	return int((material_power + weight_factor) * durability_factor)


func get_material_attack_power(material: String) -> int:
	match material:
		"iron": return 6
		"steel": return 10
		"wood": return 5
		"glass": return 3
		"bronze": return 8
		"leather": return 4
		_ : return 6  # Default attack power


func calculate_resistance(item: ItemResource, damage_type: String) -> int:
	if item.resistances.has(damage_type):
		return item.resistances[damage_type]
	return 0  # No resistance if damage type is not listed


func apply_item_effects(item: ItemResource) -> void:
	for effect in item.item_effects:
		match effect:
			"increase_strength":
				# Apply strength buff (example effect)
				apply_strength_buff()
			"heal":
				return
				# Apply healing effect
			_:
				print("Unknown effect: %s" % effect)

# Example function for strength buff
func apply_strength_buff():
	print("Player's strength increased!")

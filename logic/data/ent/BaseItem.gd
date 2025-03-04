extends Resource
class_name BaseItem

@export var name: String = "Unnamed Item" # Item's name
@export var description: String = "No description" # Detailed item description
@export var item_type: String = "Generic" # Type of item (e.g., "Usable", "Weapon", "Quest", etc.)
@export var weight: float = 1.0 # Item weight, used for inventory systems with weight limits
@export var value: int = 1 # Monetary or trade value of the item
@export var rarity: String = "Common" # Rarity tier (e.g., "Common", "Rare", "Legendary")

### **Ownership and Acquisition**
@export var owner: String = "Null" # Current owner of the item (e.g., player, NPC)
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
@export var durability: int = 100 # Weapon durability
@export var is_two_handed: bool = false # If the weapon requires two hands

### **Miscellaneous Variables**
@export var stackable: bool = false # Whether multiple items of the same type can stack
@export var max_stack: int = 1 # Maximum stack size (if stackable)
@export var interactable_with_world: bool = true # If the item can interact with the world (e.g., tree branches)

### **Dynamic or Procedural Variables**
@export var is_dynamic: bool = false # Indicates if the item is procedurally generated
@export var generation_seed: int = 0 # Seed for procedural generation

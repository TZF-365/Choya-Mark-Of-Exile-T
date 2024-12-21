extends Resource
class_name Item 

@export var name: String
@export var Item: String 

@export_enum("sword", "dagger", "fist")
var equip : String = "Weapon"

@export_enum("Healthy", "Hurt", "Injured", "Dead")
var pstatus : String = ""

@export var nameis: String = ""
@export var vitality_points: int = 0
@export var max_vitality: int = 100
@export var current_vitality: int = 100
@export var max_stamina: int = 100
@export var current_stamina: int = 100
@export var exhaustion: float = 0.0
@export var stability: float = 1.0
@export_multiline var description: String

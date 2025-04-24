extends Resource
class_name Technique_

@export var name: String
@export var description: String
@export var attack_type: String = "light" # "light", "heavy", "special", "finisher", etc.
@export var stance_required: String = ""

@export var scaling_stat: String = "strength"
@export var scaling_factor: float = 0.1  
@export var flat_bonus: float = 0.0  
@export var armor_bonus_table := {
	"none": 0.0,
	"leather": 0.0,
	"iron": 0.0,
	"steel": 0.0,
	"silver": 0.0,
	"iron_mail": 0.0,
	"steel_mail": 0.0,
	"iron_plate": 0.0,
	"steel_plate": 0.0,
	"composite": 0.0,
	"iron_brigandine": 0.0,
	"iron_scale": 0.0,
	"steel_scale": 0.0,
	"steel_Brigandine": 0.0
}


@export var base_multiplier: float = 1.0
@export var bonus_when_low_hp: float = 0.0
@export var requires_momentum: int = 0
@export var extra_momentum_bonus: float = 0.0

# Optional callable condition
var trigger_condition: Callable


func power_multiplier(actor: BaseChar) -> int:
	var stat_value = actor.stats.get(scaling_stat, 0)
	return base_multiplier + 1.0
	
	
	

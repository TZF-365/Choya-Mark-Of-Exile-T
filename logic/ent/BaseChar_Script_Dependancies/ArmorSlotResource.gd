extends Resource
class_name ArmorSlotsResource

@export_group("Armour Slots")
@export var head: ArmorResource
@export var chest: ArmorResource
@export var arms: ArmorResource
@export var legs: ArmorResource
@export var shield: ArmorResource

func to_dict() -> Dictionary:
	return {
		"head": head,
		"chest": chest,
		"arms": arms,
		"legs": legs,
		"shield": shield
	}

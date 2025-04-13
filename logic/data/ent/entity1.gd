extends Node
# base Entity class that holds all the necessary variables 
# and functions that define the core properties and behaviors 
# of any entity. This includes things like health, stamina, mana, 
# damage modifiers, movement, and so on. This class will be the 
# foundation for other entities.
class_name entity1

#core entity or main entity stats
@export var core_entity = {
	"name": "",
	"entity_type": "",
	"Level": 1,
	"Exp": 0,
	"faction": "",
	"stance": "",
	"Val": 100,
	"vitality_points": 3,  # Points available for investment
	"max_mana": 50,
	"Sta": 30,
	"mana": 34,
	"current_mana": 50,
	"max_stamina": 100,
	"current_stamina": 100,
	"exhaustion": 0.0,
	"stability": 1.0,
	"coins": 0,
	"status": 1,
	
	
	"body_parts": {
		"head": {"health": 50, "hit_modifier": 0.8, "damage_multiplier": 2.0},
		"neck": {"health": 100, "hit_modifier": 1.0, "damage_multiplier": 1.0},
		"chest": {"health": 100, "hit_modifier": 1.0, "damage_multiplier": 1.0},
		"leftarm": {"health": 100, "hit_modifier": 1.0, "damage_multiplier": 1.0},
		"rightarm": {"health": 100, "hit_modifier": 1.0, "damage_multiplier": 1.0},
		"torso": {"health": 100, "hit_modifier": 1.0, "damage_multiplier": 1.0, "bleed_resistance": 0.2},
		"leftleg": {"health": 80, "hit_modifier": 0.8, "damage_multiplier": 1.0, "stability_reduction": 0.2},
		"rightleg": {"health": 100, "hit_modifier": 1.0, "damage_multiplier": 1.0},
	},
	
	"damage_types": {
		"physical": {"resistance": 0.1, "vulnerability": 0.0},
		"fire": {"resistance": 0.0, "vulnerability": 0.2},
		"ice": {"resistance": 0.2, "vulnerability": 0.0},
		"poison": {"resistance": 0.15, "vulnerability": 0.0}
	},
	
	"equipment": {
		"weapon": {"name": "Sword", "damage_modifier": 10, "element": "fire"},
		"armor": {"name": "Leather Armor", "defense_modifier": 5, "bleed_resistance": 0.1},
		"accessory": {"name": "Amulet of Mana", "mana_efficiency": 0.2},
	},
	"relative_position": "front",
	"reach": 5.0
}

# Vitality Traits
@export var vitality_traits: Dictionary = {
	"toughness": 0,
	"bleed_resistance": 0,
	"poison_resistance": 0,
	"observation": 0,
	"mana_efficiency": 0,
	"stamina_recovery": 0,
	"exhaustion_resistance": 0
}

func calculate_damage(body_part: Dictionary) -> int:
	var base_damage = core_entity["damage"]
	var damage = base_damage * body_part["hit_modifier"]
	return int(damage)


func attack(target: Node, body_part: String):
	var target_part = target.core_entity["body_parts"].get(body_part, null)
	if target_part:
		var damage = calculate_damage(target_part)
		target.take_damage(damage, body_part)
		print("%s attacked %s's %s for %d damage!" % [core_entity["name"], target.core_entity["name"], body_part, damage])

func die():
	print("%s has been defeated!" % core_entity["name"])

func take_damage(amount: int, body_part: String):
	core_entity["body_parts"][body_part]["health"] -= amount
	core_entity["current_health"] -= amount
	print("%s's %s is damaged! Remaining health: %d" % [core_entity["name"], body_part, core_entity["body_parts"][body_part]["health"]])
	if core_entity["current_health"] <= 0:
		die()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

extends Node
class_name Weapon_Proficiency_DB

# Each weapon type defines its entire proficiency curve explicitly.
# Percentages are ADDITIVE (DUHHHH) per level and applied multiplicatively to base weapon power.

const WEAPON_PROFICIENCIES := {

	"sword": {
		"base_power": 4,
		"max_level": 7,
		"xp_per_level": 200,
		"level_bonuses": [0.06, 0.06, 0.06, 0.18, 0.18, 0.18, 0.18]
	},
	"dagger": {
		"base_power": 3,
		"max_level": 7,
		"xp_per_level": 200,
		"level_bonuses": [0.06, 0.06, 0.06, 0.18, 0.18, 0.18, 0.18]
	},

	"short_sword": {
		"base_power": 5,
		"max_level": 8,
		"xp_per_level": 230,
		"level_bonuses": [0.12, 0.12, 0.12, 0.12, 0.12, 0.12, 0.12, 0.12]
	},

	"longsword": {
		"base_power": 7,
		"max_level": 10,
		"xp_per_level": 300,
		"level_bonuses": [
			0.15, 0.15, 0.15, 0.15, 0.15,
			0.15, 0.15, 0.15, 0.15, 0.15
		]
	},

	"greatsword": {
		"base_power": 11,
		"max_level": 8,
		"xp_per_level": 380,
		"level_bonuses": [0.10, 0.10, 0.10, 0.10, 0.25, 0.25, 0.25, 0.25]
	},

# has a higher consistant crit chance but no oppertunity or finisher atacks characters first weapon.
	"club": {
		"base_power": 6,
		"max_level": 6,
		"xp_per_level": 150,
		"level_bonuses": [0.20, 0.20, 0.20, 0.08, 0.08, 0.08]
	},

	"mace": {
		"base_power": 9,
		"max_level": 7,
		"xp_per_level": 500,
		"level_bonuses": [0.14, 0.14, 0.14, 0.14, 0.14, 0.14, 0.14]
	},
#weapons that have a base damage of 10 or more requires 5 action points.
	"war_hammer": {
		"base_power": 13,
		"max_level": 6,
		"xp_per_level": 850,
		"level_bonuses": [0.30, 0.30, 0.10, 0.10, 0.10, 0.10]
	},

	"axe_1h": {
		"base_power": 8,
		"max_level": 7,
		"xp_per_level": 233,
		"level_bonuses": [0.18, 0.18, 0.18, 0.18, 0.08, 0.08, 0.08]
	},

	"great_axe": {
		"base_power": 12,
		"max_level": 6,
		"xp_per_level": 420,
		"level_bonuses": [0.25, 0.25, 0.25, 0.12, 0.12, 0.12]
	},
# edit so you gain more damage near the middle than the end, all spears give more buffs near the middle
	"spear": {
		"base_power": 6,
		"max_level": 9,
		"xp_per_level": 380,
		"level_bonuses": [0.11, 0.11, 0.11, 0.11, 0.11, 0.11, 0.11, 0.11, 0.11]
	},

	"halberd": {
		"base_power": 10,
		"max_level": 8,
		"xp_per_level": 340,
		"level_bonuses": [0.12, 0.12, 0.12, 0.12, 0.20, 0.20, 0.20, 0.20]
	},
# buffs from str and dex and adds damage from arrows. also just more customizable
	"bow": {
		"base_power": 5,
		"max_level": 10,
		"xp_per_level": 280,
		"level_bonuses": [
			0.13, 0.13, 0.13, 0.13, 0.13,
			0.13, 0.13, 0.13, 0.13, 0.13
		]
	},
#you can only use a crossbow every other turn, and at level 3 you can equip it in your off hand. and gain a reaction skill for it. 
	"crossbow": {
		"base_power": 7,
		"max_level": 6,
		"xp_per_level": 360,
		"level_bonuses": [0.18, 0.18, 0.18, 0.18, 0.18, 0.18]
	},

	"sling": {
		"base_power": 4,
		"max_level": 5,
		"xp_per_level": 220,
		"level_bonuses": [0.10, 0.15, 0.25, 0.30, 0.35]
	},

	"staff": {
		"base_power": 5,
		"max_level": 9,
		"xp_per_level": 260,
		"level_bonuses": [0.10, 0.10, 0.10, 0.10, 0.10, 0.10, 0.10, 0.10, 0.10]
	},

	"whip": {
		"base_power": 4,
		"max_level": 8,
		"xp_per_level": 310,
		"level_bonuses": [0.08, 0.08, 0.08, 0.08, 0.08, 0.22, 0.22, 0.22]
	},

	"improvised": {
		"base_power": 3,
		"max_level": 4,
		"xp_per_level": 120,
		"level_bonuses": [0.15, 0.15, 0.15, 0.15]
	},

	"katana": {
		"base_power": 8,
		"max_level": 16,
		"xp_per_level": 360,
		"level_bonuses": [
			0.09, 0.09, 0.09, 0.09, 0.09, 0.09,
			0.12, 0.12, 0.12, 0.12, 0.12, 0.12,
			0.20, 0.20, 0.20, 0.20
		]
	},

	"chain_blades": {
		"base_power": 6,
		"max_level": 12,
		"xp_per_level": 330,
		"level_bonuses": [
			0.08, 0.08, 0.08, 0.08, 0.08, 0.08,
			0.15, 0.15, 0.15, 0.15,
			0.25, 0.25
		]
	},

	"meteor_hammer": {
		"base_power": 9,
		"max_level": 9,
		"xp_per_level": 390,
		"level_bonuses": [0.05, 0.05, 0.05, 0.18, 0.18, 0.18, 0.18, 0.30, 0.30]
	},

	"scythe": {
		"base_power": 10,
		"max_level": 8,
		"xp_per_level": 350,
		"level_bonuses": [0.12, 0.12, 0.12, 0.12, 0.22, 0.22, 0.22, 0.22]
	}
}


func get_proficiency_multiplier(weapon_type: String, level: int) -> float:
	if not WEAPON_PROFICIENCIES.has(weapon_type):
		return 1.0

	var data = WEAPON_PROFICIENCIES[weapon_type]
	level = clamp(level, 0, data.max_level)

	var multiplier := 1.0
	for i in range(level):
		multiplier += data.level_bonuses[i]

	return multiplier

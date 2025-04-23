@tool
extends EditorScript

const SAVE_PATH := "res://logic/data/resources/Items/weapons/" # Make sure this folder exists in your project
const WeaponResource = preload("res://logic/data/resources/WeaponResource.gd") # Change this to your actual WeaponResource path

func _run():
	var templates = [
		{
			"id": "iron_guard_sword",
			"name": "Sword of the Iron Guard",
			"material": "iron",
			"weight": 1.4,
			"class": "Sword",
			"crit": 0.1,
			"reach": 1.0,
			"parry": 0.2,
			"traits": ["balanced", "military"]
		},
		{
			"id": "steel_greatsword",
			"name": "Steel Greatsword",
			"material": "steel",
			"weight": 3.1,
			"class": "Greatsword",
			"crit": 0.15,
			"reach": 1.3,
			"parry": 0.1,
			"traits": ["heavy", "two_handed"]
		},
		{
			"id": "bronze_dagger",
			"name": "Bronze Dagger",
			"material": "bronze",
			"weight": 0.6,
			"class": "Dagger",
			"crit": 0.25,
			"reach": 0.6,
			"parry": 0.05,
			"traits": ["light", "quick"]
		},
		{
			"id": "glass_rapier",
			"name": "Shimmering Glass Rapier",
			"material": "glass",
			"weight": 1.0,
			"class": "Rapier",
			"crit": 0.3,
			"reach": 1.2,
			"parry": 0.15,
			"traits": ["fragile", "precise"]
		},
		{
			"id": "wooden_staff",
			"name": "Oak Channeling Staff",
			"material": "wood",
			"weight": 2.2,
			"class": "Staff",
			"crit": 0.05,
			"reach": 1.5,
			"parry": 0.1,
			"traits": ["blunt", "arcane_focus"]
		},
		{
			"id": "leather_whip",
			"name": "Beastmaster's Whip",
			"material": "leather",
			"weight": 0.9,
			"class": "Whip",
			"crit": 0.18,
			"reach": 1.8,
			"parry": 0.05,
			"traits": ["entangle", "reach", "light"]
		},
		{
			"id": "steel_warhammer",
			"name": "Crushing Steel Warhammer",
			"material": "steel",
			"weight": 2.6,
			"class": "Warhammer",
			"crit": 0.08,
			"reach": 1.0,
			"parry": 0.1,
			"traits": ["blunt", "armor_piercing", "slow"]
		},
		{
			"id": "bronze_spear",
			"name": "Bronze-Tipped Spear",
			"material": "bronze",
			"weight": 2.7,
			"class": "Spear",
			"crit": 0.12,
			"reach": 1.7,
			"parry": 0.1,
			"traits": ["reach", "piercing"]
		},
		{
			"id": "iron_mace",
			"name": "Iron Spiked Mace",
			"material": "iron",
			"weight": 2.3,
			"class": "Mace",
			"crit": 0.07,
			"reach": 0.9,
			"parry": 0.1,
			"traits": ["blunt", "spiked", "stunning"]
		},
		{
			"id": "steel_katana",
			"name": "Steel Moon Katana",
			"material": "steel",
			"weight": 1.3,
			"class": "Katana",
			"crit": 0.2,
			"reach": 1.1,
			"parry": 0.25,
			"traits": ["sharp", "counter", "precision"]
		}
	]

	for weapon_data in templates:
		var weapon = WeaponResource.new()
		weapon.id = weapon_data["id"]
		weapon.name = weapon_data["name"]
		weapon.material = weapon_data["material"]
		weapon.weight = weapon_data["weight"]
		weapon.weapon_class = weapon_data["class"]
		weapon.critical_chance = weapon_data["crit"]
		weapon.reach = weapon_data["reach"]
		weapon.parry_bonus = weapon_data["parry"]
		weapon.weapon_traits = weapon_data["traits"]
		weapon.is_weapon = true

		var save_file_path = "%s%s.tres" % [SAVE_PATH, weapon_data["id"]]
		ResourceSaver.save(weapon, save_file_path)
		print("Saved: ", save_file_path)

	print("✅ Weapon templates generated.")

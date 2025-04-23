@tool
extends EditorScript

const SAVE_PATH := "res://logic/data/resources/Items/armors/"
const ArmorResource = preload("res://logic/data/resources/ArmorResource.gd")

# Base stats per class
const CLASS_STATS = {
	"Plate": { "durability_base": 60, "reduction": 0.26, "price_mult": 12 },
	"Leather": { "durability_base": 35, "reduction": 0.15, "price_mult": 6 },
	"Blubber": { "durability_base": 40, "reduction": 0.2, "price_mult": 4 },
	"Fat": { "durability_base": 45, "reduction": 0.25, "price_mult": 5 },
	"Scale": { "durability_base": 64, "reduction": 0.24, "price_mult": 10 },
	"Hide": { "durability_base": 42, "reduction": 0.18, "price_mult": 7 },
	"Shield": { "durability_base": 75, "reduction": 0.4, "price_mult": 15 },
}

func _run():
	var templates = [
		{ "id": "iron_plate", "name": "Iron Plate Armor", "material": "iron", "weight": 5.0, "class": "Plate", "traits": ["heavy", "rigid", "military"] },
		{ "id": "leather_vest", "name": "Reinforced Leather Vest", "material": "leather", "weight": 2.2, "class": "Leather", "traits": ["light", "flexible", "stealthy"] },
		{ "id": "blubber_coat", "name": "Thick Blubber Coat", "material": "blubber", "weight": 3.5, "class": "Blubber", "traits": ["cold_resistant", "soft"] },
		{ "id": "fat_padding", "name": "Fat Padding", "material": "fat", "weight": 4.0, "class": "Fat", "traits": ["blunt_absorb", "warm"] },
		{ "id": "scale_mail", "name": "Bronze Scale Mail", "material": "bronze", "weight": 4.2, "class": "Scale", "traits": ["scaly", "versatile"] },
		{ "id": "hide_armor", "name": "Thick Hide Armor", "material": "hide", "weight": 3.8, "class": "Hide", "traits": ["natural", "rugged"] },
		{ "id": "tower_shield", "name": "Steel Tower Shield", "material": "steel", "weight": 6.0, "class": "Shield", "traits": ["block", "heavy", "cover"] }
	]

	for armor_data in templates:
		var stats = CLASS_STATS.get(armor_data["class"], {})

		var durability = stats.get("durability_base", 50) * 2
		var reduction = stats.get("reduction", 0.2)
		var price = int(durability * reduction * stats.get("price_mult", 5))
		var desc = "A %s made of %s. Offers %.0f%% damage reduction and weighs %.1f kg." % [
			armor_data["name"].to_lower(),
			armor_data["material"],
			reduction * 100,
			armor_data["weight"]
		]

		var armor = ArmorResource.new()
		armor.id = armor_data["id"]
		armor.name = armor_data["name"]
		armor.material = armor_data["material"]
		armor.weight = armor_data["weight"]
		armor.armor_class = armor_data["class"]
		armor.damage_reduction = reduction
		armor.durability = durability
		armor.max_durability = durability
		armor.armor_traits = armor_data["traits"]
		armor.price = price
		armor.description = desc
		armor.is_armor = true

		var save_file_path = "%s%s.tres" % [SAVE_PATH, armor_data["id"]]
		var result = ResourceSaver.save(armor, save_file_path)
		if result == OK:
			print("✅ Saved: ", save_file_path)
		else:
			print("❌ Failed to save: ", save_file_path)

	print("🎉 Armor templates generated.")

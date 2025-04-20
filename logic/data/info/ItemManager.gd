class_name ItemManager
extends Node

const ItemResource = preload("res://logic/data/resources/ItemResource.gd")

var items: Dictionary = {}  # Holds all loaded items by ID
var inventory: Array = []    # Player’s inventory of items
var equipped_items: Dictionary = {}  # Player's equipped items

# Load an item from a JSON or a resource file
func load_item(item_id: String) -> ItemResource:
	if not items.has(item_id):
		var item_resource = load("res://items/%s.tres" % item_id)
		items[item_id] = item_resource
	return items[item_id]

# Add an item to the inventory
func add_item_to_inventory(item_id: String):
	var item = load_item(item_id)
	inventory.append(item)

# Use an item (e.g., consumable or weapon)
func use_item(item_id: String) -> String:
	var item = load_item(item_id)
	var result_text = ""
	
	if item.type == "consumable":
		result_text = item.combat_data["custom_use_text"]
		item.uses -= 1
		apply_item_effects(item)  # Apply effects
		
	if item.uses <= 0:
		result_text += " This item is now used up."
		remove_item_from_inventory(item.id)
			
	return result_text
	
func apply_item_effects(item: ItemResource):
	# Placeholder logic
	print("Applying effects for item: ", item.name)


func remove_item_from_inventory(item_id: String):
	for i in range(inventory.size()):
		if inventory[i].resource_path.ends_with("%s.tres" % item_id):
			inventory.remove_at(i)
			break

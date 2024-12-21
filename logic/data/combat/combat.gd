extends entitymanager

@onready var entity_manager = EntityManager.new()
@onready var rich_text_label = $RichTextLabel  # Assuming you have a RichTextLabel in your scene


func _ready():
	# Clear the label initially
	rich_text_label.clear()
	
	# Add some initial entities or logic if needed
	entity_manager.debug_print_entities()

	# Add entities to the EntityManager
	var entity_manager = EntityManager.new()
	
# Button click function to create a new entity
func _on_add_entity_button_pressed() -> void:
	var unique_id = "entity_" + str(1)  # Use the current time for a unique ID
	var new_entity = Entity.new(unique_id, "Player")  # Create a new entity with a name "Player"

func _update_entity_info(entity: Entity) -> void:
	var text = "New Entity Created!\n"
	text += "ID: %s\n" % entity.id
	text += "Name: %s\n" % entity.name
	# Append the text to RichTextLabel
	rich_text_label.append_bbcode("[color=green]" + text + "[/color]")





	# Add the entity to the manager
	entity_manager.add_entity(unique_id, new_entity)

	# Show entity info in the RichTextLabel
	_update_entity_info(new_entity)
	
	
	
	
	
	entity_manager.add_entity("player_hero", player)
	entity_manager.add_entity("enemy_goblin", goblin)

	# Testing entity interactions
	player.take_damage(10)  # Player takes damage
	goblin.attack()  # Goblin attacks

	# Print entities
	entity_manager.debug_print_entities()  # Should print player and goblin details


	# Testing entity interactions
	player.take_damage(10)  # Player takes damage
	goblin.attack()  # Goblin attacks

	# Print entities
	entity_manager.debug_print_entities()  # Should print player and goblin details

extends entity

class_name EntityManager

# A dictionary to store entities by their unique IDs
var entities: Dictionary = {}

# Signal emitted when an entity is added or removed
signal entity_added(entity_id: String, entity: Node)
signal entity_removed(entity_id: String)

### ENTITY MANAGEMENT ###

# Add an entity to the manager
func add_entity(entity_id: String, entity: Node) -> void:
	if entities.has(entity_id):
		push_error("Entity with ID '%s' already exists!" % entity_id)
		return
	entities[entity_id] = entity
	emit_signal("entity_added", entity_id, entity)
	print("Entity '%s' added successfully." % entity_id)

# Remove an entity from the manager
func remove_entity(entity_id: String) -> void:
	if not entities.has(entity_id):
		push_error("Entity with ID '%s' does not exist!" % entity_id)
		return
	entities.erase(entity_id)
	emit_signal("entity_removed", entity_id)
	print("Entity '%s' removed successfully." % entity_id)

# Get an entity by its ID
func get_entity(entity_id: String) -> Node:
	return entities.get(entity_id, null)

### ENTITY UPDATES ###

# Update all entities (e.g., for animations, AI, etc.)
func update_entities(delta: float) -> void:
	for entity_id in entities.keys():
		if "update" in entities[entity_id]:
			entities[entity_id].update(delta)

# Reset specific entity stats or perform a global reset
func reset_all_entities() -> void:
	for entity_id in entities.keys():
		entities[entity_id].reset_stats()

### UTILITY FUNCTIONS ###

# Get all entities of a specific type
func get_entities_by_type(entity_type: String) -> Array:
	var filtered_entities = []
	for entity in entities.values():
		if entity.is_class(entity_type):
			filtered_entities.append(entity)
	return filtered_entities

# Count the total number of entities
func get_entity_count() -> int:
	return entities.size()

# Check if an entity exists
func has_entity(entity_id: String) -> bool:
	return entities.has(entity_id)

# Debugging function to print all entities
func debug_print_entities() -> void:
	print("Current entities:")
	for entity_id in entities.keys():
		print("- %s: %s" % [entity_id, entities[entity_id]])
		

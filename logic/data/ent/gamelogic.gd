extends Node

@onready var entity_var_node = $entity_var
@onready var player_stats
@onready var is_dead

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if entity_var_node == null:
		print("Error: Entity_Var is null!")
		return
	
	if entity_var_node is entity_var:
		player_stats = $entity_var.stat 
		print("Player stats:", player_stats)
	else:
		print("Error: Entity_Var is not of type 'entity_var'")
		
	if player_stats["health"] <=0:
		is_dead = true 
		print("No numbers here")
	else:
		print("there are numbers here")
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node
class_name Combat_Data

var player:  BaseChar = null
var enemy_instance: BaseChar = null      # optional: an instantiated BaseChar (Node)
var enemy_id: String = ""            # <-- must exist and be String (or remove type hint)
var enemy_config: Dictionary = {}  # Will be empty if using default
var battle_events: Array = []

func clear():
	player = null
	enemy_instance = null
	enemy_id = ""
	enemy_config = {}
	battle_events = []
	print("Combat data loaded")
	print("CombatData type:", CombatData.get_class())       # should print "Combat_Data" if class_name used
	print("CombatData script path:", CombatData.get_script())  # debug info
	print("Has enemy_id property (via get):", CombatData.get("enemy_id"))  # returns value or null

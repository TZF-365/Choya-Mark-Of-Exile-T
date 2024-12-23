extends BaseChar

# Additional player-specific properties or methods
var is_enemy: bool = true

func _ready():
	name = "Goblin"
	max_health = 100
	stats["strength"] = 12
	stats["endurance"] = 8

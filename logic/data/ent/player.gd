extends BaseChar

# Additional player-specific properties or methods
var is_player: bool = true

func _ready():
	name = "Player"
	max_health = 100
	stats["strength"] = 12
	stats["endurance"] = 8

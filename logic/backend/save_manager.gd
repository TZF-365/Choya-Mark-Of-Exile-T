extends Node
class_name SaveManager


var config = ConfigFile.new()

var data:= Ccid     # Should have a "current_page" variable
var player_stats: BaseChar = Player_AL # Must have Val, mana, health, etc.
var save_key = "Antigua@Barbuda"


# --- Save the game ---
func save_game(data_dict: Dictionary) -> void:
	if data_dict.has("player_stats"):
		for key in data_dict["player_stats"].keys():
			config.set_value("player_stats", key, data_dict["player_stats"][key])

	if data_dict.has("current_page"):
		config.set_value("story", "current_page", data_dict["current_page"])

	config.save_encrypted_pass("user://settings.cfg", save_key)
	print("✅ Game Saved:", data_dict)

# --- Load the game ---
func load_game() -> Dictionary:
	var result = config.load_encrypted_pass("user://settings.cfg", save_key)
	if result != OK:
		printerr("❌ Failed to load save file!")
		return {}

	var loaded_data := {
		"player_stats": {
			"health": config.get_value("player_stats", "health"),
			"mana": config.get_value("player_stats", "mana"),
			"coins": config.get_value("player_stats", "coins"),
		},
		"current_page": config.get_value("story", "current_page", "000_prologue")
	}

	print("✅ Game Loaded:", loaded_data)
	return loaded_data


# --- Save using live data from the game ---
func save_current_game() -> void:
	if player_stats == null:
		printerr("Missing player_statsreference!")
	if data == null:
		printerr("Missing data reference!")
		return

	var game_data = {
		"player_stats": {
			"health": player_stats.current_hp,
			"mana": player_stats.mana,
			"coins": player_stats.coins,
		},
		"current_page": data.get("current_page")
	}

	save_game(game_data)


# --- Load and apply to live game ---
func load_current_game() -> void:
	if player_stats == null or data == null:
		printerr("Missing player_stats or data reference!")
		return

	var loaded = load_game()
	if loaded.is_empty():
		return

	# Update in-game values
	var stats = loaded["player_stats"]
	player_stats.current_hp = stats["health"]
	player_stats.mana = stats["mana"]
	player_stats.coins = stats["coins"]

	# Set the current page from the loaded data
	if data.has_method("set_page"):
		data.call("set_page", loaded["current_page"])

	# Retrieve the JSON content of the loaded page
	print("🎮 Game state applied to player and story")



func start_new_game() -> void:
	if player_stats == null or data == null:
		printerr("❌ Missing player_stats or data reference!")
		return

	# Reset player stats to default values
	player_stats.val = 0
	player_stats.mana = 100
	player_stats.coins = 0  # Optional if you use coins

	# Set the starting page
	var starting_page = "000_prologue"
	data.set("current_page", starting_page)

	# Update the UI/game to show that page
	if data.has_method("set_content") and data.content_dict.has(starting_page):
		data.set_content(data.content_dict[starting_page])

	# Save the new initial state
	save_game({
		"player_stats": {
			"val": player_stats.current_val,
			"mana": player_stats.mana,
			"coins": player_stats.coins,
		},
		"current_page": starting_page
	})

	print("🆕 New game started and default state saved")

extends Node
class_name SaveManager

var config = ConfigFile.new()

var data := Ccid               # Has current_page, current_chapter_id
var player_stats: BaseChar = Player_AL  # Has val, mana, health, etc.
var content_data := ContentData         # Global singleton with phraseNum
var save_key = "Antigua@Barbuda"

# --- Save the game ---
func save_game(data_dict: Dictionary) -> void:
	if data_dict.has("player_stats"):
		for key in data_dict["player_stats"].keys():
			config.set_value("player_stats", key, data_dict["player_stats"][key])

	if data_dict.has("current_page"):
		config.set_value("story", "current_page", data_dict["current_page"])
		config.set_value("story", "current_chapter_id", data_dict["current_chapter_id"])

	if data_dict.has("phrase_num"):
		config.set_value("story", "phrase_num", data_dict["phrase_num"])

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
		"current_page": config.get_value("story", "current_page", "000_prologue"),
		"current_chapter_id": config.get_value("story", "current_chapter_id", "000_prologue"),
		"phrase_num": config.get_value("story", "phrase_num", 0)
	}

	print("✅ Game Loaded:", loaded_data)
	return loaded_data

# --- Save using live data from the game ---
func save_current_game() -> void:
	if player_stats == null:
		printerr("❌ Missing player_stats reference!")
	if data == null or content_data == null:
		printerr("❌ Missing data or content_data reference!")
		return

	var game_data = {
		"player_stats": {
			"health": player_stats.current_hp,
			"mana": player_stats.mana,
			"coins": player_stats.coins,
		},
		"current_page": data.current_page,
		"current_chapter_id": data.current_chapter_id,
		"phrase_num": content_data.phraseNum
	}

	save_game(game_data)

# --- Load and apply to live game ---
func load_current_game() -> void:
	if player_stats == null or data == null or content_data == null:
		printerr("❌ Missing references to player_stats, data, or content_data!")
		return

	var loaded = load_game()
	if loaded.is_empty():
		return
	ContentData.load_content_dict()

	# Update player stats
	var stats = loaded["player_stats"]
	player_stats.current_hp = stats["health"]
	player_stats.mana = stats["mana"]
	player_stats.coins = stats["coins"]

	# Apply phrase number
	content_data.phraseNum = loaded.get("phrase_num")

	# Set the current page
	if data.has_method("set_page"):
		data.set_page(loaded["current_page"])
	elif "current_page" in data:
		data.current_page = loaded["current_page"]

	# Display story content
	if data.has_method("set_content_from_current_page"):
		data.set_content_from_current_page()

	print("🎮 Game state applied to player and story")




#################### --- Start a brand new game ---
func start_new_game() -> void:
	if player_stats == null or data == null or content_data == null:
		printerr("❌ Missing player_stats, data, or content_data reference!")
		return

	# Reset player stats
	player_stats.val = 0
	player_stats.mana = 100
	player_stats.coins = 0

	# Set the starting page
	var starting_page = "000_prologue"
	data.set_page(starting_page)

	# Initialize phrase
	content_data.phraseNum = 0

	# Set initial content
	if data.has_method("set_content_from_current_page"):
		data.set_content_from_current_page()

	# Save the initial state
	save_game({
		"player_stats": {
			"health": player_stats.current_hp,
			"mana": player_stats.mana,
			"coins": player_stats.coins,
		},
		"current_page": starting_page,
		"current_chapter_id": starting_page,
		"phrase_num": 0
	})

	print("🆕 New game started and default state saved")

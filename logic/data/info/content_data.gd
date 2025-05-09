extends Node
#Content data 2.0 supporting multiple script scanning!

# Path to the dialog files
var dialogPath: Array = [
	"res://story/Sample_Story.json",
	"res://story/tavern1.json",
	"res://story/game_over.json",
]

# Current phrase number
static var phraseNum : int = 0
# Flag to indicate if the dialog is finished
var finished :bool = false
# Dictionary that contains all the text content of the game
static var content_dict: Dictionary = {}


# Called when the node is added to the scene
func _ready():
	# Load the content dictionary from the dialog files
	load_content_dict()
	print("Game Scripts Loaded")

# Function to load the content dictionary
func load_content_dict():
	for path in dialogPath:
		# Check if the file exists
		if not FileAccess.file_exists(path):
			push_error("File path does not exist: %s" % path)
			continue
		
		# Open the file for reading
		var f = FileAccess.open(path, FileAccess.ModeFlags.READ)
		if f == null:
			push_error("Failed to open file: %s" % path)
			continue
		
		# Read the content of the file as text
		var json = f.get_as_text()
		var json_object = JSON.new()
		
		# Parse the JSON text
		var parse_result = json_object.parse(json)
		if parse_result != OK:
			push_error("Failed to parse JSON in file: %s" % path)
			continue
		
		# Merge the parsed data into the content dictionary
		for key in json_object.data.keys():
			if content_dict.has(key):
				push_error("Duplicate key found: %s. Overwriting existing data." % key)
				print("Duplicate key found: %s. Overwriting existing data." % key)
			content_dict[key] = json_object.data[key]

# Return the value of content_dict
func get_content_dict() -> Dictionary:
	return content_dict

# Function to move to the next phrase in the dialog
func nextPhrase():
	# Check if the current phrase number is greater than or equal to the number of phrases
	if phraseNum >= len(content_dict):
		# If so, do not proceed (potentially end the dialog)
		# queue_free() # This line is commented out; it would free the node
		return
	# Set finished flag to false
	finished = false



# Call this method when you want to load all story content
static func load_all():
	content_dict.clear()  # Clean out old data first

	var dir := DirAccess.open("res://story/")  # Adjust path as needed
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):
				var file_path = "res://story/" + file_name
				var file = FileAccess.open(file_path, FileAccess.READ)
				if file:
					var json = JSON.parse_string(file.get_as_text())
					if json is Dictionary:
						content_dict.merge(json, true)
					else:
						printerr("⚠️ Invalid JSON in file:", file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		printerr("⚠️ Could not open chapters folder!")

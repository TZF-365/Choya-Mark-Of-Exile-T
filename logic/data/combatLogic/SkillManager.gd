# SkillManager.gd
extends Node

var skills_database: Dictionary = {}  # This will hold the available skill resources
var character_skills: Dictionary = {}  # This will hold skills assigned to each character

# Example to load the skill resources (you can export these from Godot editor or create via code)
func _ready():
	# Load skill resources
	var fireball_skill = preload("res://logic/data/resources/Skills/fireball.tres")

	
	# Store these loaded skills in the skills database
	skills_database["Fireball"] = fireball_skill

# Assign skill to a character
func assign_skill(character: BaseChar, skill_name: String):
	if skills_database.has(skill_name):
		var skill = skills_database[skill_name]
		character.add_skill(skill)
		self.character_skills[character] = self.character_skills.get(character, [])
		self.character_skills[character].append(skill)
		print(character.name + " has learned " + skill_name)
		print("Trying to use skill: ", skill_name)
	else:
		print("Skill not found in the database: " + skill_name)
		

# Get character skills
func get_character_skills(character: BaseChar) -> Array:
	return self.character_skills.get(character, [])

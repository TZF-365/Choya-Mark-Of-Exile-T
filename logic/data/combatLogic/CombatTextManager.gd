extends Node

var templates: Dictionary

@export var dialogPath = "res://story/combat_text.json"
var combat_content_text: Dictionary = {}

#func _ready():
#	templates = JSON.parse(FileAccess.read_all_text("res://story/combat_text.json")).result
#	load_combat_content_text()
	
func get_random_template(category: String, key: String) -> String:
	var list = templates.get(category, {}).get(key, [])
	if list.size() == 0:
		return ""
	return list[randi() % list.size()]

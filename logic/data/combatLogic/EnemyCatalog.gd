extends Node
class_name Enemy_Catalog

# Enemy templates (authoring layer)
@export var enemy_templates: Dictionary = {
	"bandit": preload("res://logic/data/enemies/bandit.tscn"),
	"bandit_leader": preload("res://logic/data/enemies/bandit_leader.tscn"),
	"thug": preload("res://logic/data/enemies/thug.tscn"),

	"goblin": preload("res://logic/data/enemies/goblin.tscn"),
	"goblin_shaman": preload("res://logic/data/enemies/goblin_shaman.tscn"),
	"goblin_king": preload("res://logic/data/enemies/goblin_king.tscn"),

	"wolf": preload("res://logic/data/enemies/wolf.tscn"),
	"dire_wolf": preload("res://logic/data/enemies/dire_wolf.tscn"),

	"skeleton": preload("res://logic/data/enemies/skeleton.tscn"),
	"skeleton_knight": preload("res://logic/data/enemies/skeleton_knight.tscn"),

	"training_dummy": preload("res://logic/data/enemies/training_dummy.tscn")
}


# Categorization & metadata
@export var enemy_categories: Dictionary = {
	"humanoid": ["bandit", "bandit_leader"],
	"beast": ["wolf", "bear"]
}

@export var enemy_tags: Dictionary = {
	"bandit": ["humanoid", "criminal", "light_armor"],
	"goblin_king": ["humanoid", "boss"]
}

# Difficulty scaling presets
@export var difficulty_presets := {
	"easy": { "hp_mult": 0.75, "stat_bonus": 0 },
	"normal": { "hp_mult": 1.0, "stat_bonus": 0 },
	"hard": { "hp_mult": 1.25, "stat_bonus": 2 },
	"elite": { "hp_mult": 1.5, "stat_bonus": 4 }
}

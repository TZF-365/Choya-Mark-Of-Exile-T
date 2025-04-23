extends Node

var techniques: Dictionary = {}

func _ready():
		# Preload techniques here — name them as keys
	techniques["charge"] = preload("res://logic/data/resources/Techniques/charge.tres")
	techniques["cleave"] = preload("res://logic/data/resources/Techniques/cleave.tres")
	techniques["hack"] = preload("res://logic/data/resources/Techniques/hack.tres")
	techniques["quick_jab"] = preload("res://logic/data/resources/Techniques/quick_jab.tres")
	techniques["riposte"] = preload("res://logic/data/resources/Techniques/riposte.tres")
	# ... add more here as needed


func load_all_techniques(path: String):
	var dir = DirAccess.open(path)
	if dir == null:
		printerr("TechniqueManager: Failed to open directory at %s" % path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var full_path = path + "/" + file_name
			var technique = load(full_path)
			if technique is Technique_:
				techniques[technique.name] = technique
		file_name = dir.get_next()
	dir.list_dir_end()

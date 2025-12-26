# StoryFlags.gd (autoload)
extends Node

var flags: Dictionary = {}

func set_flag(flag_name: String, value: bool = true):
	flags[flag_name] = value

func has_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

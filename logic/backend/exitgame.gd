extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func exit_game():
	# Add your game over logic here, such as:
	# - Playing a game over sound effect
	# - Displaying a game over screen
	# - Saving game data (if necessary)
	# - Delaying before quitting

	# Example:
	print("Game Over!")
	get_tree().quit()

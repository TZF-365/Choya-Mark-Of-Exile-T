extends ChoiceM
class_name CSLogic

<<<<<<< HEAD
<<<<<<< Updated upstream
<<<<<<< HEAD
=======
>>>>>>> Stashed changes
var save_manager = SaveManager.new()
@onready var stat = $entity_var.core_entity 
=======
@onready var entity_var

@onready var stat = $entity_var.core_entity
>>>>>>> parent of 2a0b700 (Saves)
<<<<<<< Updated upstream
=======
@onready var entity_var

@onready var stat = $entity_var.core_entity
>>>>>>> parent of 2a0b700 (Saves)
=======
>>>>>>> Stashed changes

@onready var stats_label = $MarginContainer/VBoxContainer/Panel/HBoxContainer/Panel/Label
@onready var bcg = $MarginContainer/VBoxContainer/Panel/HBoxContainer2/Panel/BGC
@onready var style: StyleBoxFlat = StyleBoxFlat.new() #variable for setting the background

func _ready():
<<<<<<< HEAD
<<<<<<< Updated upstream
<<<<<<< HEAD
=======
>>>>>>> Stashed changes
	stats_label.text = str("Val: " + str(stat["Val"]) + ", " + "Mana: " + str(stat["mana"]) + ", " + "Coins: " + str(stat["coins"]) + "\nStatus: " + str(stat["status"]))
	# Create an instance of SaveManager when the scene is ready
	# Save the game data at the start
	save_manager.save_game(current_page, stat)
	print_tree_pretty()
=======
	stats_label.text = str("Val: "+str(stat["Val"])+", "+"Mana: "+str(stat["mana"])+ ", "+"Coins: "+str(stat["coins"])+"\nStatus: "+str(stat["status"]))
>>>>>>> parent of 2a0b700 (Saves)
<<<<<<< Updated upstream
=======
	stats_label.text = str("Val: "+str(stat["Val"])+", "+"Mana: "+str(stat["mana"])+ ", "+"Coins: "+str(stat["coins"])+"\nStatus: "+str(stat["status"]))
>>>>>>> parent of 2a0b700 (Saves)
=======
>>>>>>> Stashed changes


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
<<<<<<< HEAD
<<<<<<< Updated upstream
<<<<<<< HEAD
=======
>>>>>>> Stashed changes
	stats_label.text = str("Val: " + str(stat["Val"]) + ", " + "Mana: " + str(stat["mana"]) + ", " + "Coins: " + str(stat["coins"]) + "\nStatus: " + str(stat["status"]))

	# Create an instance of SaveManager to save the game every frame
	save_manager.save_game(current_page, stat)

=======
	stats_label.text = str("Val: "+str(stat["Val"])+", "+"Mana: "+str(stat["mana"])+ ", "+"Coins: "+str(stat["coins"])+"\nStatus: "+str(stat["status"]))
	
>>>>>>> parent of 2a0b700 (Saves)
<<<<<<< Updated upstream
=======
	stats_label.text = str("Val: "+str(stat["Val"])+", "+"Mana: "+str(stat["mana"])+ ", "+"Coins: "+str(stat["coins"])+"\nStatus: "+str(stat["status"]))
	
>>>>>>> parent of 2a0b700 (Saves)
=======
>>>>>>> Stashed changes
	if "Val" in stat:  # Ensure "Val" exists in the dictionary
		if int(stat["Val"]) <= 1:
			stat["Val"] = 0



func _on_button_pressed():
	OS.shell_open("https://www.glenvilledixonjr.com") # goes to website when pressed.


func _on_menu_pressed() -> void:
<<<<<<< HEAD
<<<<<<< Updated upstream
<<<<<<< HEAD
=======
>>>>>>> Stashed changes
	save_manager.save_game(current_page, stat)

=======
>>>>>>> parent of 2a0b700 (Saves)
<<<<<<< Updated upstream
=======
>>>>>>> parent of 2a0b700 (Saves)
=======
>>>>>>> Stashed changes
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_exitbutton_pressed() -> void:
	get_tree().quit() # quits game when pressed.
	


func _on_button_pressed_combat() -> void:
	get_tree().change_scene_to_file("res://scenes/combat_screen.tscn")
	
	
	



func _on_bgc_pressed() -> void: #How to change the background image for the background
	style.bg_color = Color.GREEN

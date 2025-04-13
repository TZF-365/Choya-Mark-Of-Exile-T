extends PanelContainer
class_name CSLogic

@onready var entity_var

@onready var stat = $entity_var.core_entity

@onready var stats_label = $MarginContainer/VBoxContainer/Panel/HBoxContainer/Panel/Label
@onready var bcg = $MarginContainer/VBoxContainer/Panel/HBoxContainer2/Panel/BGC
@onready var style: StyleBoxFlat = StyleBoxFlat.new() #variable for setting the background

func _ready():
	stats_label.text = str("Val: "+str(stat["Val"])+", "+"Mana: "+str(stat["mana"])+ ", "+"Coins: "+str(stat["coins"])+"\nStatus: "+str(stat["status"]))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	stats_label.text = str("Val: "+str(stat["Val"])+", "+"Mana: "+str(stat["mana"])+ ", "+"Coins: "+str(stat["coins"])+"\nStatus: "+str(stat["status"]))
	
	if "Val" in stat:  # Ensure "Val" exists in the dictionary
		if int(stat["Val"]) <= 1:
			stat["Val"] = 0



func _on_button_pressed():
	OS.shell_open("https://www.glenvilledixonjr.com") # goes to website when pressed.


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_exitbutton_pressed() -> void:
	get_tree().quit() # quits game when pressed.
	


func _on_button_pressed_combat() -> void:
	get_tree().change_scene_to_file("res://scenes/combat_screen.tscn")
	
	
	



func _on_bgc_pressed() -> void: #How to change the background image for the background
	style.bg_color = Color.GREEN
	add_theme_stylebox_override("panel", style)

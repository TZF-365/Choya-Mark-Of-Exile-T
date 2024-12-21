extends entity

@onready var entity_var = $entity_var
@onready var stat = $entity_var.stat
@onready var action: Button = $"Main_Screen/Control/Input Screens/Panel/action buttons/Panel/Action"
@onready var inspect: Button = $"Main_Screen/Control/Input Screens/Panel/action buttons/Panel/Inspect"
@onready var items: Button = $"Main_Screen/Control/Input Screens/Panel/action buttons/Panel/Items"
@onready var move: Button = $"Main_Screen/Control/Input Screens/Panel/action buttons/Panel/Move"
@onready var label: Label = $Main_Screen/Control/InfoCombatScreens/VBoxContainer/InfoPanels/CombatPanel/HBoxContainer/Panel/HSeparator/MarginContainer/Panel/Enemystats/Panel/vbox/Label3
@onready var playerstat: Label = $"Main_Screen/Control/InfoCombatScreens/VBoxContainer/InfoPanels/PlayerInfoPanel/HBoxContainer/Panel/Player Stats"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerstat.text = str("Val: "+str(stat["Val"])+"\n "+"Sta: "+str(stat["Sta"])+"\n "+str("Mana: "+str(stat["mana"])))




func _on_move_pressed() -> void:
	label.set_text(str("you moved"))

func _on_Menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_screen.tscn")


func _on_action_pressed() -> void:
	label.set_text(str("You clicked action"))


func _on_inspect_pressed() -> void:
	label.set_text(str("You did an inspection"))


func _on_items_pressed() -> void:
	label.set_text(str("You Got an Item"))


func _on_turn_pressed() -> void:
	pass # Replace with function body.


func _on_tactical_overview_pressed() -> void:
	pass # Replace with function body.


func _on_panel_pressed() -> void:
	pass # Replace with function body.


func _on_help_pressed() -> void:
	pass # Replace with function body.

extends PanelContainer
class_name CSLogic
var current_chapter: String
var stat: Dictionary
var start_page: String
@onready var stats : BaseChar = Player_AL
@onready var SaveManager = $SaveManager

@onready var entity_var = Player_AL

@onready var stats_label = $MarginContainer/VBoxContainer/Panel/HBoxContainer/Panel/Label
@onready var save = $MarginContainer/VBoxContainer/Panel/HBoxContainer2/Panel/Save
@onready var load = $MarginContainer/VBoxContainer/Panel/HBoxContainer2/Panel/Load

@onready var style: StyleBoxFlat = StyleBoxFlat.new() # variable for setting the background




func _ready():
	await AudioManager.fade_out_music()
	AudioManager.play_music(preload("res://assets/Music/Scene1.ogg"))
	stats_label.text = str("val: " + str(stats["current_val"]) + ", " + "Mana: " + str(stats["mana"]) + ", " + "Coins: " + str(stats["coins"]) + "\nStatus: " + str(stats["status"]))
	print(stats_label.text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	stats_label.text = str("Val: " + str(stats["current_val"]) + ", " + "Mana: " + str(stats["mana"]) + ", " + "Coins: " + str(stats["coins"]) + "\nStatus: " + str(stats["status"]))


func set_custom_defaults(new_defaults: Dictionary) -> void:
	for key in new_defaults.keys():
		if key in stats:
			stats[key] = new_defaults[key]
		else:
			push_warning("Key '%s' not found in base stats, adding it anyway." % key)
			stats[key] = new_defaults[key]
			


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


func _on_bgc_pressed() -> void: # How to change the background image for the background
	style.bg_color = Color.GREEN
	add_theme_stylebox_override("panel", style)


func _on_save_pressed() -> void:
	SaveManager.save_current_game()


func _on_load_pressed() -> void:
	SaveManager.load_current_game()

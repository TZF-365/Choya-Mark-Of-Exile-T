extends Control

enum Menu { MAIN_MENU, SETTINGS_MENU }
@export var start_button : Button
@export var settings_button : Button
@export var exit_button : Button
@export var SceneTransitionManager = "res://scenes/utilities/scene_transition_manager.tscn"
@export var start_scene_path : PackedScene
@export var transition_path : PackedScene

@onready var SaveManager = $"../../SaveManager"

var current_menu : Menu = Menu.MAIN_MENU

func _enter_tree():
	start_button.pressed.connect(_on_start_button_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
func _exit_tree():
	start_button.pressed.disconnect(_on_start_button_pressed)
	settings_button.pressed.disconnect(_on_settings_pressed)
	exit_button.pressed.disconnect(_on_exit_pressed)

func _on_start_button_pressed():
	# Start the transition (wait for it to finish before continuing)
	TransitionManager.transition(0.5)
	# Wait for the transition to finish using the "on_transition_finished" signal
	await TransitionManager.on_transition_finished

	# After transition, change the scene
	get_tree().change_scene_to_file("res://scenes/game_screen.tscn")



func _on_exit_pressed():
	get_tree().quit()


func _on_settings_pressed():
	current_menu = Menu.SETTINGS_MENU


func _on_return_main_menu_button_pressed():
	current_menu = Menu.MAIN_MENU


func _on_load_button_pressed() -> void:
	# Start the transition (wait for it to finish before continuing)
	TransitionManager.transition(0.5)
	# Wait for the transition to finish using the "on_transition_finished" signal
	await TransitionManager.on_transition_finished
	$"../../SaveManager".load_current_game()
	get_tree().change_scene_to_file("res://scenes/game_screen.tscn")
	

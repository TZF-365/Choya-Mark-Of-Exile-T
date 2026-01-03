extends Control

enum Menu { MAIN_MENU, SETTINGS_MENU }
@export var start_button : Button
@export var settings_button : Button
@export var exit_button : Button
@export var SceneTransitionManager = "res://scenes/utilities/scene_transition_manager.tscn"
@export var start_scene_path : PackedScene
@export var transition_path : PackedScene

@onready var SaveManager = SaveManager_Node.new()

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
	AudioManager.play_sfx_music_by_name("menubutton", -20)
	# Start the transition (wait for it to finish before continuing)
	TransitionManager.transition(0.3)
	# Wait for the transition to finish using the "on_transition_finished" signal
	await TransitionManager.on_transition_finished
	# After transition, change the scene
	Scene.change("res://scenes/game_screen.tscn")



func _on_exit_pressed():
	AudioManager.play_sfx_music_by_name("menubutton", -20)
	await get_tree().create_timer(3.0).timeout
	get_tree().quit()


func _on_settings_pressed():
	AudioManager.play_sfx_music_by_name("menubutton", -20)
	current_menu = Menu.SETTINGS_MENU


func _on_return_main_menu_buthealth_is_zeroton_pressed():
	current_menu = Menu.MAIN_MENU
	AudioManager.play_sfx_music_by_name("menubutton", -20)


func _on_load_button_pressed() -> void:
	# Start fade-out
	AudioManager.play_sfx_music_by_name("menubutton", -20)
	TransitionManager.transition(0.3)
	await TransitionManager.on_transition_finished
	# Load save data (data-only)
	await SaveManager.load_current_game()

	# Change scene (DO NOT await)
	Scene.change("res://scenes/game_screen.tscn")

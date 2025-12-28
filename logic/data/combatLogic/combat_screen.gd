extends Node

@onready var action: Button = $"Main_Screen/Control/Input Screens/Panel/action buttons/Panel/Action"
@onready var inspect: Button = $"Main_Screen/Control/Input Screens/Panel/action buttons/Panel/Inspect"
@onready var items: Button = $"Main_Screen/Control/Input Screens/Panel/action buttons/Panel/Items"
@onready var move: Button = $"Main_Screen/Control/Input Screens/Panel/action buttons/Panel/Move"
@onready var label: Label = $Main_Screen/Control/InfoCombatScreens/VBoxContainer/InfoPanels/CombatPanel/HBoxContainer/Panel/HSeparator/MarginContainer/Panel/Enemystats/Panel/vbox/Label3
@onready var playerstat: Label = $"Main_Screen/Control/InfoCombatScreens/VBoxContainer/InfoPanels/PlayerInfoPanel/HBoxContainer/Panel/Player Stats"

@onready var SaveManager = $SaveManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.set_music_fade_enabled(true)
	AudioManager.play_music(preload("res://assets/Music/03_Melee.ogg"))
	for i in range(max_displayed_points):
		var icon := TextureRect.new()
		icon.texture = action_point_icon
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(10, 10)
		icon.modulate.a = 0.25
		ap_container.add_child(icon)
		current_icons.append(icon)
		icon_display_states.append(0.25)


@export var action_point_icon: Texture2D


@onready var ap_container: HBoxContainer = $"Main_Screen/Control/Input Screens/Panel/actionchainnbutton/VBoxContainer/Panel/MarginContainer/VBoxContainer/Button2/MarginContainer/APContainer"

@export var max_displayed_points: int = 7

var current_icons: Array = []
var icon_display_states: Array = []  # Tracks alpha of each icon
var ap_tween: Tween = null




func update_action_points(current: int, max_points: int) -> void:
	current = clamp(current, 0, max_points)

	# Kill previous tween if any
	if ap_tween:
		ap_tween.kill()
	ap_tween = create_tween()

	# Remove old icons
	for child in ap_container.get_children():
		child.queue_free()
	current_icons.clear()

	var fade_time := 0.02
	var delay_step := 0.05

	# Recreate icons
	for i in range(max_points):
		var icon := TextureRect.new()
		icon.texture = action_point_icon
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(10, 10)
		icon.modulate.a = 0.0  # start invisible
		ap_container.add_child(icon)
		current_icons.append(icon)

		# Target alpha
		var target_alpha := 1.0 if i < current else 0.25

		# Tween alpha with a small delay per icon
		ap_tween.tween_property(icon, "modulate:a", target_alpha, fade_time).set_delay(i * delay_step)

		# Optional pop effect
		ap_tween.tween_property(icon, "scale", Vector2(1.2, 1.2), fade_time / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		ap_tween.tween_property(icon, "scale", Vector2(1, 1), fade_time / 2).set_delay(fade_time / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)






func bind_actor(actor: BaseChar) -> void:
	if actor.action_points_changed.is_connected(update_action_points):
		actor.action_points_changed.disconnect(update_action_points)

	actor.action_points_changed.connect(update_action_points)
	update_action_points(actor.action_points, actor.max_action_points)


func _on_move_pressed() -> void:
	label.set_text(str("you moved"))
	

func _on_Menu_button_pressed() -> void:
	# Start the transition (wait for it to finish before continuing)
	TransitionManager.transition(0.5)
	# Wait for the transition to finish using the "on_transition_finished" signal
	await TransitionManager.on_transition_finished
	Scene.change("res://scenes/game_screen.tscn")


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

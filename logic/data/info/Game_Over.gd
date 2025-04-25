extends PanelContainer
class_name GameOver

@onready var flavorinfo: Label = $MarginContainer/HBoxContainer2/Panel/Flavorinfo
@onready var background: Panel = $MarginContainer/VBoxContainer/Panel

var fade_colors = [
	Color(0.2, 0.1, 0.3),  # Dark purple
	Color(0.1, 0.2, 0.4),  # Deep blue
	Color(0.3, 0.1, 0.1),  # Blood red
	Color(0.1, 0.3, 0.2),  # Forest green
	Color(0.2, 0.2, 0.2)   # Neutral dark
]

var current_color_index = 0

var flavor_texts = [
	"In the ruins of Talbot, echoes of valor still haunt the wind.",
	"Legends say a Drukdar wept once—when it saw the courage of humankind.",
	"Magic surges may have passed, but the scars they left remain eternal.",
	"The blades forged in Talbot cut more than flesh—they cut through fate itself.",
	"Even in defeat, the will of the Arkenhome never fades.",
	"Some say the mana storms were not the end, but the beginning of something greater.",
	"Not all monsters live in caves—some wear the faces of friends.",
	"Your fall is but a whisper in the long saga of humanity's survival.",
	"They once feared the dark, until they became it. So too may you rise."
]

func _ready():
	randomize()
	flavorinfo.text = flavor_texts[randi() % flavor_texts.size()]

	AudioManager.fade_out_music()
	AudioManager.play_music(preload("res://assets/Music/Beru_vs_S-Rank_Hunters_OPME.mp3"))

	_start_fade_loop()


func _start_fade_loop():
	var next_index = (current_color_index + 1) % fade_colors.size()
	var from_color = fade_colors[current_color_index]
	var to_color = fade_colors[next_index]

	background.modulate = from_color

	var tween = get_tree().create_tween()
	tween.tween_property(background, "modulate", to_color, 3.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "_on_fade_complete"))

	current_color_index = next_index


func _on_fade_complete():
	_start_fade_loop()


func _on_button_pressed():
	OS.shell_open("https://www.glenvilledixonjr.com")


func _on_exitbutton_pressed() -> void:
	get_tree().quit()


func _on_main_menu_pressed() -> void:
	TransitionManager.transition(0.5)
	await TransitionManager.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

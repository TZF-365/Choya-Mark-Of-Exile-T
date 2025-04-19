extends CanvasLayer

signal on_transition_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

enum TransitionType {
	FADE_BLACK,
	FADE_WHITE,
	IRIS,
	SHATTER,
	SYMBOL_WIPE,
	ASH_DISSOLVE,
	FOG_FADE,
	GLITCH
}


var transition_duration: float = 1.0  # Default duration of 1 second

func _ready():
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

# Call this function with a custom duration for the transition
func transition(duration: float = 1.0):
	transition_duration = duration
	color_rect.visible = true
	animation_player.speed_scale = 1.0 / transition_duration  # Adjust speed based on the duration
	animation_player.play("Fadein")  # Play the Fadein animation with the adjusted speed

# Handle when the animation finishes
func _on_animation_finished(anim_name: String):
	if anim_name == "Fadein":
		on_transition_finished.emit()  # Emit the signal when Fadein is finished
		animation_player.play("Fadeout")  # Play the Fadeout animation
	elif anim_name == "Fadeout":
		color_rect.visible = false  # Hide the color rect after the fadeout

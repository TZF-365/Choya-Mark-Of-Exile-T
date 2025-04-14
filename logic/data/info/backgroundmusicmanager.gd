extends Node
class_name Music_Manager


@export var audio_player: AudioStreamPlayer
@export var audio_player2: AudioStreamPlayer
@export var sound_effect_player: AudioStreamPlayer
@onready var timer: Timer

# Dictionary of audio streams (optional if loading via files or inspector)
var scene_audio_streams = {
	"main_menu": preload("res://assets/Music/Calmingmusic.mp3"),
	"battlestart": preload("res://assets/Music/Battle1Start.ogg"),
	"Battlemusic": preload("res://assets/Music/03_Melee.ogg"), 
	"victory": preload("res://assets/Music/2000_Peace.ogg"),
	"Village1": preload("res://assets/Music/Scene1.ogg"),
}

# Call this to change the background music
func play_scene_audio(scene_key: String):
	if scene_audio_streams.has(scene_key):
		audio_player.stream = scene_audio_streams[scene_key]
		audio_player.play()
	else:
		print("Audio for scene '%s' not found!" % scene_key)




# List of songs to play
@onready var songs = [
	preload("res://assets/Music/Dandadan_OPMED.mp3"),
	preload("res://assets/Music/Chainsaw-Man-OPMED.mp3"),
	preload("res://assets/Music/battlemusic.mp3"),
	preload("res://assets/Music/Calmingmusic.mp3"),
	preload("res://assets/Music/orchestra-fantasy.mp3")
]

var current_song_index = 0

func _ready():
	# Start playing the first song
	# play_song(current_song_index)
<<<<<<< HEAD
<<<<<<< Updated upstream
<<<<<<< HEAD
	play_scene_audio("Silentforest")
=======
=======
>>>>>>> parent of 2a0b700 (Saves)
=======
	play_scene_audio("Silentforest")
=======
>>>>>>> Stashed changes
	play_scene_audio("main_menu")
	
	
	# Configure the timer
	timer.start()
	timer.wait_time = 90.0  # Time in seconds before switching songs
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)  # Updated to use Callable

func play_song(index: int):
	# Assign and play the song
	audio_player.stream = songs[index]
	audio_player.play()
	print("Playing song: ", songs[index].resource_path)

func _on_timer_timeout():
	# Move to the next song
	if current_song_index <= 1:
		current_song_index += 1
		_ready()
		print("Next song Playing")
	else:
		current_song_index = 0  # Loop back to the first song
		play_song(current_song_index)
		print("Music has Looped")
		_ready()
<<<<<<< Updated upstream
<<<<<<< HEAD
>>>>>>> parent of 2a0b700 (Saves)
=======
=======
>>>>>>> Stashed changes
>>>>>>> parent of 2a0b700 (Saves)

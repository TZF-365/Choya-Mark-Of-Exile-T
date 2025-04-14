extends Node

var num_players = 8
var bus = "SFX"

var available = []  # The available players.
var queue = []  # The queue of sounds to play.

<<<<<<< HEAD
<<<<<<< HEAD
@export var audio_player: AudioStreamPlayer
@export var audio_player2: AudioStreamPlayer
@export var sound_effects_player: AudioStreamPlayer
@onready var timer = $"../AudioStreamPlayer/Timer"

# Dictionary of audio streams (optional if loading via files or inspector)
var scene_audio_streams = {
	"main_menu": preload("res://assets/Music/Calmingmusic.mp3"),
	"battlestart": preload("res://assets/Music/Battle1Start.ogg"),
	"Battlemusic": preload("res://assets/Music/03_Melee.ogg"), 
	"victory": preload("res://assets/Music/2000_Peace.ogg"),
	"Village1": preload("res://assets/Music/Scene1.ogg"),
	"Silentforest": preload("res://assets/Music/i_just_want_to_go_home.mp3")
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
=======
>>>>>>> parent of 2a0b700 (Saves)
=======
>>>>>>> parent of 2a0b700 (Saves)

func _ready():
	# Create the pool of AudioStreamPlayer nodes.
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = bus


func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	available.append(stream)


func play(sound_path):
	queue.append(sound_path)


func _process(_delta):
	# Play a queued sound if any players are available.
	if not queue.is_empty() and not available.is_empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()

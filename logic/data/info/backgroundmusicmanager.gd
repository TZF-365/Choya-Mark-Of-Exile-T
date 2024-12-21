extends Node

@onready var audio_player = $"../AudioStreamPlayer"
@onready var timer = $"../AudioStreamPlayer/Timer"

# List of songs to play
@onready var songs = [
	preload("res://assets/Music/battlemusic.mp3"),
	preload("res://assets/Music/music.mp3"),
	preload("res://assets/Music/orchestra-fantasy.mp3")
]

var current_song_index = 0

func _ready():
	# Start playing the first song
	play_song(current_song_index)
	
	# Configure the timer
	timer.start(12)
	timer.wait_time = 8.0  # Time in seconds before switching songs
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

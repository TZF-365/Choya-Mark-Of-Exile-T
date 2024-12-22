extends Node

@onready var audio_player = $"../soundeffectplayer"
@onready var timer = $"../AudioStreamPlayer/Timer"

# List of songs to play
@onready var songs = [
	preload("res://assets/Music/buttonpress.mp3")
]

var current_song_index = 0


func play_song(index: int):
	# Assign and play the song
	
	audio_player.stream = songs[index]
	audio_player.play(0.22)
	print("Playing song: ", songs[index].resource_path)


func _on_button_pressed() -> void:
	play_song(current_song_index)

extends Node

@onready var audio_player = $"../soundeffectplayer"
@onready var timer = $"../AudioStreamPlayer/Timer"

# List of songs to play
@onready var songs = preload("res://assets/Music/buttonpress.mp3")

#func play_song(index: int):
	# Assign and play the song
	
	#audio_player.stream = songs
	#audio_player.play(0.0)
	#print("Playing song: ", songs.resource_path)
	#print(songs)


func _on_button_pressed() -> void:
	AudioManager.play_sfx_music_by_name("button", -20)
	print("Playing song: ", songs.resource_path)
	print(songs)

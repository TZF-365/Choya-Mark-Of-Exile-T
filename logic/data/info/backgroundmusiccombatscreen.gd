extends music_manager

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

func _ready():
	# Start playing the first song
	# play_song(current_song_index)
	play_scene_audio("Battlemusic")

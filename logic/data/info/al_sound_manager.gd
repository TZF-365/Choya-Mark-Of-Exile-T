extends Node
class_name Audio_Manager

@onready var music_player_a: AudioStreamPlayer = $"MusicPlayerA"
@onready var music_player_b: AudioStreamPlayer = $"MusicPlayerB"
@onready var sfx_player: AudioStreamPlayer = $"SFXPlayer"
@onready var music_timer: Timer = $Timer
var custom_loop_enabled := false
var loop_start_time := 0.0
var loop_end_time := 0.0


# Toggle between A and B for crossfade
var current_player_is_a := true
var current_player = 0
var fade_duration := 2.0


# Scene-specific tracks
var scene_audio_streams = {
	"main_menu": preload("res://assets/Music/Calmingmusic.mp3"),
	"battlestart": preload("res://assets/Music/Battle1Start.ogg"),
	"Battlemusic": preload("res://assets/Music/03_Melee.ogg"),
	"victory": preload("res://assets/Music/2000_Peace.ogg"),
	"Village1": preload("res://assets/Music/Scene1.ogg"),
}


# Playlist for timed songs
@onready var songs = [
	preload("res://assets/Music/Dandadan_OPMED.mp3"),
	preload("res://assets/Music/Chainsaw-Man-OPMED.mp3"),
	preload("res://assets/Music/battlemusic.mp3"),
	preload("res://assets/Music/Calmingmusic.mp3"),
	preload("res://assets/Music/orchestra-fantasy.mp3")
]


var current_song_index := 0

func _ready():
	music_timer.wait_time = 50.0
	music_timer.one_shot = false
	music_timer.timeout.connect(_on_music_timer_timeout)
	music_timer.start()
	print("AudioManager ready.")

func play_music(stream: AudioStream):
	if current_player == 0:
		music_player_a.stream = stream
		music_player_a.play()
		current_player = 1
	else:
		music_player_b.stream = stream
		music_player_b.play()
		current_player = 0
		
		
func fade_in_music():
	if current_player == 0:
		music_player_a.volume_db = -80
		music_player_a.play()
		music_player_a.volume_db = 0
	else:
		music_player_b.volume_db = -80
		music_player_b.play()
		music_player_b.volume_db = 0

func stop_music():
	music_player_a.stop()
	music_player_b.stop()


# Crossfade music from one player to the other
func play_music_crossfade(stream: AudioStream):
	var from_player = music_player_a if current_player_is_a else music_player_b
	var to_player = music_player_b if current_player_is_a else music_player_a

	to_player.stream = stream
	to_player.volume_db = -80
	to_player.play()

	var tween = create_tween()
	tween.tween_property(from_player, "volume_db", -80, fade_duration)
	tween.parallel().tween_property(to_player, "volume_db", 0, fade_duration)

	await tween.finished
	from_player.stop()
	current_player_is_a = !current_player_is_a
	
func play_sfx(stream: AudioStream, duration: float = -1.0) -> void:
	sfx_player.stream = stream
	sfx_player.play()
	if duration > 0:
		await get_tree().create_timer(duration).timeout
		sfx_player.stop()

# Play music from the scene audio map
func play_scene_audio(scene_key: String):
	if scene_audio_streams.has(scene_key):
		play_music_crossfade(scene_audio_streams[scene_key])
	else:
		print("Scene key '%s' not found!" % scene_key)


# Play a sound effect (UI, click, etc.)
func play_ui_sound(stream: AudioStream):
	sfx_player.stream = stream
	sfx_player.play()


# Play a song from the list
func play_song(index: int):
	current_song_index = index % songs.size()
	play_music_crossfade(songs[current_song_index])
	print("Now playing: ", songs[current_song_index].resource_path)


# Called by the timer to rotate through songs
func _on_music_timer_timeout():
	current_song_index += 1
	play_song(current_song_index)
	
	
func play_music_with_custom_loop(stream: AudioStream, start_time: float, end_time: float):
	custom_loop_enabled = true
	loop_start_time = start_time
	loop_end_time = end_time

	# Use crossfade with A/B players
	var from_player = music_player_a if current_player_is_a else music_player_b
	var to_player = music_player_b if current_player_is_a else music_player_a

	to_player.stream = stream
	to_player.volume_db = -80
	to_player.play()
	to_player.seek(start_time)
	to_player.loop = false  # disable native loop

	var tween = create_tween()
	tween.tween_property(from_player, "volume_db", -80, fade_duration)
	tween.parallel().tween_property(to_player, "volume_db", 0, fade_duration)

	await tween.finished
	from_player.stop()
	current_player_is_a = !current_player_is_a

	# Set timer to check when to loop
	music_timer.stop()
	music_timer.wait_time = end_time - start_time
	music_timer.start()


func fade_out_music():
	var active_player = music_player_a if current_player_is_a else music_player_b
	if active_player.playing:
		var fade_out_tween = create_tween()
		fade_out_tween.tween_property(active_player, "volume_db", -80, fade_duration)
		fade_out_tween.tween_callback(Callable(active_player, "stop"))
		fade_out_tween.tween_callback(Callable(self, "_reset_volume").bind(active_player))
		
		
func _reset_volume(player: AudioStreamPlayer):
	player.volume_db = 0

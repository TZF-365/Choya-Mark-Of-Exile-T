extends Node
class_name Audio_Manager

# --- Nodes ---
@onready var music_player_a: AudioStreamPlayer = $MusicPlayerA
@onready var music_player_b: AudioStreamPlayer = $MusicPlayerB
@onready var sfx_players: Array = [$SFXPlayer1, $SFXPlayer2, $SFXPlayer3]
@onready var music_timer: Timer = $Timer

# --- Music crossfade ---
var current_player_is_a := true
var fade_duration := 2.0
var min_volume_db := -80.0

# --- Custom loop ---
var custom_loop_enabled := false
var loop_start_time := 0.0
var loop_end_time := 0.0

# --- Playlist ---
var songs: Array = [
	preload("res://assets/Music/Dandadan_OPMED.mp3"),
	preload("res://assets/Music/Chainsaw-Man-OPMED.mp3"),
	preload("res://assets/Music/battlemusic.mp3"),
	preload("res://assets/Music/Calmingmusic.mp3"),
	preload("res://assets/Music/Magical-Transition.mp3")
]
var current_song_index := 0

# --- Music Libraries ---
var sfx_music_library: Dictionary = {
	"dandadan": preload("res://assets/Music/Dandadan_OPMED.mp3"),
	"chainsaw": preload("res://assets/Music/Chainsaw-Man-OPMED.mp3"),
	"battle": preload("res://assets/Music/battlemusic.mp3"),
	"calm": preload("res://assets/Music/Calmingmusic.mp3"),
	"button": preload("res://assets/Music/buttonpress.mp3"),
	"menubutton": preload("res://assets/Music/menu_click.mp3")
}

var scene_audio_streams: Dictionary = {
	"main_menu": preload("res://assets/Music/Calmingmusic.mp3"),
	"battlestart": preload("res://assets/Music/Battle1Start.ogg"),
	"battlemusic": preload("res://assets/Music/03_Melee.ogg"),
	"victory": preload("res://assets/Music/2000_Peace.ogg"),
	"village1": preload("res://assets/Music/Scene1.ogg"),
	"aaaa": preload("res://assets/Music/I_Will_Not_Let_You.mp3")
}

func _ready():
	print("AudioManager ready.")
	music_timer.timeout.connect(Callable(self, "_on_music_timer_timeout"))

# --- Helpers ---
func _get_active_music_player() -> AudioStreamPlayer:
	return music_player_a if current_player_is_a else music_player_b

func _get_inactive_music_player() -> AudioStreamPlayer:
	return music_player_b if current_player_is_a else music_player_a

func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if player and not player.is_playing():
			return player
	return sfx_players[0] if sfx_players.size() > 0 else null

# --- SFX helper by name ---
func play_sfx_music_by_name(track_name: String, volume_db: float = 0):
	if not sfx_music_library.has(track_name):
		print("SFX music track not found:", track_name)
		return
	var stream = sfx_music_library[track_name]
	var player = _get_available_sfx_player()
	if not player:
		print("No available SFX player to play music:", track_name)
		return
	player.stop()
	player.stream = stream
	player.volume_db = volume_db
	player.play()

# --- Music playback ---
func play_music(stream: AudioStream, volume_db: float = -8.0):
	var player = _get_active_music_player()
	if not player:
		return
	player.stop()
	player.stream = stream
	player.volume_db = volume_db
	player.play()

func play_music_crossfade(stream: AudioStream, target_volume_db: float = 0.0):
	var from_player = _get_active_music_player()
	var to_player = _get_inactive_music_player()
	if not from_player or not to_player:
		return
	to_player.stop()
	to_player.stream = stream
	to_player.volume_db = min_volume_db
	to_player.play()
	var tween = create_tween()
	tween.tween_property(from_player, "volume_db", min_volume_db, fade_duration)
	tween.parallel().tween_property(to_player, "volume_db", target_volume_db, fade_duration)
	current_player_is_a = !current_player_is_a

func fade_in_music(duration: float = 2.0):
	var player = _get_active_music_player()
	if not player:
		return
	player.volume_db = min_volume_db
	player.play()
	var tween = create_tween()
	tween.tween_property(player, "volume_db", 0, duration)

func fade_out_music(duration: float = 2.0):
	var player = _get_active_music_player()
	if not player:
		return
	var tween = create_tween()
	tween.tween_property(player, "volume_db", min_volume_db, duration)
	tween.finished.connect(Callable(player, "stop"))

# --- Event music ---
func play_event_music(stream: AudioStream, crossfade: bool = true, target_volume_db: float = 0.0, fade_duration_sec: float = 2.0) -> void:
	if not stream:
		return

	var from_player = _get_active_music_player()
	var to_player = _get_inactive_music_player()
	if crossfade:
		# Smooth crossfade (same as before)
		if not from_player or not to_player:
			return
		to_player.stop()
		to_player.stream = stream
		to_player.volume_db = min_volume_db
		to_player.play()
		var tween = create_tween()
		tween.tween_property(from_player, "volume_db", min_volume_db, fade_duration_sec)
		tween.parallel().tween_property(to_player, "volume_db", target_volume_db, fade_duration_sec)
		current_player_is_a = !current_player_is_a
	else:
		# Hard switch with simultaneous fade out
		if from_player:
			var tween = create_tween()
			tween.tween_property(from_player, "volume_db", min_volume_db, fade_duration_sec)
		if to_player:
			to_player.stop()
			to_player.stream = stream
			to_player.volume_db = target_volume_db
			to_player.play()
			current_player_is_a = !current_player_is_a


# --- Event music by dictionary key ---
func play_event_music_by_key(key: String, crossfade: bool = true, target_volume_db: float = 0.0, fade_duration_sec: float = 2.0):
	var track_key = key.to_lower()
	if not scene_audio_streams.has(track_key):
		print("Music key not found in scene_audio_streams:", key)
		return
	var stream = scene_audio_streams[track_key]
	play_event_music(stream, crossfade, target_volume_db, fade_duration_sec)

func _play_music_after_fade(stream: AudioStream, volume_db: float):
	var player = _get_active_music_player()
	if player:
		player.stop()
		player.stream = stream
		player.volume_db = volume_db
		player.play()



# --- Custom loops ---
func play_music_with_custom_loop(stream: AudioStream, start_time: float, end_time: float):
	custom_loop_enabled = true
	loop_start_time = start_time
	loop_end_time = end_time
	var from_player = _get_active_music_player()
	var to_player = _get_inactive_music_player()
	if not from_player or not to_player:
		return
	to_player.stop()
	to_player.stream = stream
	to_player.seek(start_time)
	to_player.loop = false
	to_player.volume_db = 0
	to_player.play()
	var tween = create_tween()
	tween.tween_property(from_player, "volume_db", min_volume_db, fade_duration)
	tween.parallel().tween_property(to_player, "volume_db", 0, fade_duration)
	current_player_is_a = !current_player_is_a
	_start_music_timer(end_time - start_time)

func _start_music_timer(duration: float):
	music_timer.stop()
	music_timer.wait_time = duration
	music_timer.start()

func _on_music_timer_timeout():
	if custom_loop_enabled:
		var player = _get_active_music_player()
		if player and player.is_playing():
			player.seek(loop_start_time)
			_start_music_timer(loop_end_time - loop_start_time)

# --- SFX ---
func play_sfx(stream: AudioStream):
	if not stream:
		return
	var player = _get_available_sfx_player()
	if not player:
		return
	player.stop()
	player.stream = stream
	player.volume_db = 0
	player.play()

func play_ui_sound(stream: AudioStream):
	play_sfx(stream)

func play_sound_effect_with_fade(stream: AudioStream, custom_fade_duration: float = 2.0):
	if not stream:
		return
	var music = _get_active_music_player()
	if not music:
		return
	var tween = create_tween()
	tween.tween_property(music, "volume_db", min_volume_db, custom_fade_duration)
	var sfx = _get_available_sfx_player()
	if not sfx:
		return
	sfx.stop()
	sfx.stream = stream
	sfx.volume_db = 0
	sfx.play()
	tween.tween_property(music, "volume_db", 0, custom_fade_duration).set_delay(stream.get_length() - custom_fade_duration)

# --- Playlist ---
func play_song(index: int):
	if songs.size() == 0:
		return
	current_song_index = index % songs.size()
	play_music_crossfade(songs[current_song_index])
	print("Playing song: ", songs[current_song_index].resource_path)

func next_song():
	play_song(current_song_index + 1)

func play_scene_audio(scene_name: String):
	var key = scene_name.to_lower()
	if scene_audio_streams.has(key):
		play_music_crossfade(scene_audio_streams[key])
	else:
		print("Scene audio key '%s' not found!" % key)

# --- Stop all music & SFX ---
func stop_all_music():
	if music_player_a:
		music_player_a.stop()
	if music_player_b:
		music_player_b.stop()
	for sfx in sfx_players:
		if sfx:
			sfx.stop()
	music_timer.stop()
	custom_loop_enabled = false

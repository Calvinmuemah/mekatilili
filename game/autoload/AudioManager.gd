extends Node

var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE := 8

var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.9

# Preloaded / Cached audio streams
var sfx_cache: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)
	
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Master"
	add_child(ambient_player)
	
	for i in range(SFX_POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		sfx_players.append(p)
		
	_preload_audio()

func _preload_audio() -> void:
	var sfx_list := [
		"sfx_click", "sfx_dialogue_blip", "sfx_quest_start",
		"sfx_quest_complete", "sfx_item_collect", "sfx_footstep"
	]
	for sfx_item: String in sfx_list:
		var path: String = "res://assets/audio/" + sfx_item + ".wav"
		if ResourceLoader.exists(path):
			sfx_cache[sfx_item] = load(path)

func play_music(stream_path: String, fade_duration: float = 1.0) -> void:
	if not ResourceLoader.exists(stream_path):
		print("AudioManager: Music path not found: ", stream_path)
		return
	var stream := load(stream_path) as AudioStream
	if music_player.stream == stream and music_player.playing:
		return
		
	if music_player.playing and fade_duration > 0.0:
		var tween := create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(func():
			music_player.stream = stream
			music_player.volume_db = linear_to_db(music_volume * master_volume)
			music_player.play()
		)
	else:
		music_player.stream = stream
		music_player.volume_db = linear_to_db(music_volume * master_volume)
		music_player.play()

func stop_music(fade_duration: float = 1.0) -> void:
	if fade_duration > 0.0:
		var tween := create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(music_player.stop)
	else:
		music_player.stop()

func play_ambient(stream_path: String) -> void:
	if not ResourceLoader.exists(stream_path):
		return
	var stream := load(stream_path) as AudioStream
	if ambient_player.stream == stream and ambient_player.playing:
		return
	ambient_player.stream = stream
	ambient_player.volume_db = linear_to_db(0.6 * music_volume * master_volume)
	ambient_player.play()

func stop_ambient() -> void:
	ambient_player.stop()

func play_sfx(sound_name: String, pitch_scale: float = 1.0) -> void:
	var stream: AudioStream = null
	if sfx_cache.has(sound_name):
		stream = sfx_cache[sound_name]
	else:
		var path := "res://assets/audio/" + sound_name + ".wav"
		if ResourceLoader.exists(path):
			stream = load(path)
			sfx_cache[sound_name] = stream
			
	if stream == null:
		return
		
	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.pitch_scale = pitch_scale
			p.volume_db = linear_to_db(sfx_volume * master_volume)
			p.play()
			return
			
	# If all busy, steal first
	var stolen := sfx_players[0]
	stolen.stream = stream
	stolen.pitch_scale = pitch_scale
	stolen.volume_db = linear_to_db(sfx_volume * master_volume)
	stolen.play()

func set_master_volume(val: float) -> void:
	master_volume = clampf(val, 0.0, 1.0)
	_update_volumes()

func set_music_volume(val: float) -> void:
	music_volume = clampf(val, 0.0, 1.0)
	_update_volumes()

func set_sfx_volume(val: float) -> void:
	sfx_volume = clampf(val, 0.0, 1.0)
	_update_volumes()

func _update_volumes() -> void:
	if music_player != null:
		music_player.volume_db = linear_to_db(music_volume * master_volume)
	if ambient_player != null:
		ambient_player.volume_db = linear_to_db(0.6 * music_volume * master_volume)

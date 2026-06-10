## SoundManager — Autoload singleton for all SFX
## Attach as autoload in project.godot (already configured).
## When a real WAV asset is available, use AudioStreamWAV.load_from_buffer() or
## preload("res://assets/sfx/unlock.wav") and pass it to play().
extends Node

# AudioStreamPlayer pool for fire-and-forget SFX
var _player_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE := 8

# Audio settings — toggle and volume control, persisted via SaveManager.
var sfx_enabled := true
var sfx_volume := 1.0

func _ready() -> void:
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % i
		add_child(player)
		_player_pool.append(player)

# ---------------------------------------------------------------------------
# Audio settings API
# ---------------------------------------------------------------------------

func is_sfx_enabled() -> bool:
	return sfx_enabled

func set_sfx_enabled(enabled: bool) -> void:
	sfx_enabled = enabled

func get_sfx_volume() -> float:
	return sfx_volume

func set_sfx_volume(volume: float) -> void:
	sfx_volume = _sanitize_volume(volume)

## Apply settings loaded from a save file. Missing or invalid values fall
## back to the existing/default values so old saves never break.
func apply_audio_settings(settings: Dictionary) -> void:
	if settings.has("sfx_enabled"):
		sfx_enabled = bool(settings.get("sfx_enabled", true))
	if settings.has("sfx_volume"):
		sfx_volume = _sanitize_volume(settings.get("sfx_volume", 1.0))

## Returns a plain Dictionary suitable for storing in the save file.
func get_audio_settings() -> Dictionary:
	return {
		"sfx_enabled": sfx_enabled,
		"sfx_volume": sfx_volume,
	}

func _sanitize_volume(value) -> float:
	var volume := 1.0
	if value is float or value is int:
		volume = float(value)
	if is_nan(volume) or is_inf(volume):
		return 1.0
	return clampf(volume, 0.0, 1.0)

func _volume_db() -> float:
	if sfx_volume <= 0.0:
		return -80.0
	return linear_to_db(sfx_volume)

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Play a one-shot AudioStream. Pass null to use a generated beep placeholder.
func play(stream: AudioStream, volume_db: float = 0.0) -> void:
	if not sfx_enabled or sfx_volume <= 0.0:
		return
	var player := _get_free_player()
	if player == null:
		return
	player.stream = stream
	player.volume_db = volume_db + _volume_db()
	player.play()

## Played when a new decoration is unlocked.
## Phase 1: generates a simple programmatic beep via AudioStreamGenerator.
func play_unlock_decor_sound() -> void:
	# TODO Phase 2: replace with a real SFX asset from Kenney's music pack.
	if not sfx_enabled or sfx_volume <= 0.0:
		return
	var player := _get_free_player()
	if player == null:
		return

	var gen := AudioStreamGenerator.new()
	gen.mix_rate = 22050.0
	gen.buffer_length = 0.3
	player.stream = gen
	player.volume_db = _volume_db()
	player.play()

	# Push a short 880 Hz sine burst into the generator buffer
	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return
	var frames := playback.get_frames_available()
	for i in frames:
		var t := float(i) / gen.mix_rate
		var sample := sin(TAU * 880.0 * t) * exp(-t * 8.0)
		playback.push_frame(Vector2(sample, sample))

## Played when a quest is accepted.
func play_quest_accept_sound() -> void:
	if not sfx_enabled or sfx_volume <= 0.0:
		return
	var player := _get_free_player()
	if player == null:
		return

	var gen := AudioStreamGenerator.new()
	gen.mix_rate = 22050.0
	gen.buffer_length = 0.2
	player.stream = gen
	player.volume_db = _volume_db()
	player.play()

	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return
	var frames := playback.get_frames_available()
	for i in frames:
		var t := float(i) / gen.mix_rate
		var sample := sin(TAU * 440.0 * t) * exp(-t * 12.0)
		playback.push_frame(Vector2(sample, sample))

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

func _get_free_player() -> AudioStreamPlayer:
	for player in _player_pool:
		if not player.playing:
			return player
	# All busy — reuse the first one (oldest sound gets cut)
	return _player_pool[0]

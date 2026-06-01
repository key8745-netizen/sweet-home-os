## SoundManager — Autoload singleton for all SFX
## Attach as autoload in project.godot (already configured).
## When a real WAV asset is available, use AudioStreamWAV.load_from_buffer() or
## preload("res://assets/sfx/unlock.wav") and pass it to play().
extends Node

# AudioStreamPlayer pool for fire-and-forget SFX
var _player_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE := 8

func _ready() -> void:
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % i
		add_child(player)
		_player_pool.append(player)

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Play a one-shot AudioStream. Pass null to use a generated beep placeholder.
func play(stream: AudioStream, volume_db: float = 0.0) -> void:
	var player := _get_free_player()
	if player == null:
		return
	player.stream = stream
	player.volume_db = volume_db
	player.play()

## Played when a new decoration is unlocked.
## Phase 1: generates a simple programmatic beep via AudioStreamGenerator.
func play_unlock_decor_sound() -> void:
	# TODO Phase 2: replace with a real SFX asset from Kenney's music pack.
	var player := _get_free_player()
	if player == null:
		return

	var gen := AudioStreamGenerator.new()
	gen.mix_rate = 22050.0
	gen.buffer_length = 0.3
	player.stream = gen
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
	var player := _get_free_player()
	if player == null:
		return

	var gen := AudioStreamGenerator.new()
	gen.mix_rate = 22050.0
	gen.buffer_length = 0.2
	player.stream = gen
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

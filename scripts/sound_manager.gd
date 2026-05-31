extends Node

# Procedural 8-bit arpeggio for decoration unlock celebrations.
# No external audio files needed — generates samples at runtime.

const SAMPLE_RATE := 22050
const ARPEGGIO_NOTES := [523.25, 659.25, 783.99, 1046.50]  # C5 E5 G5 C6
const NOTE_DURATION := 0.08


func play_unlock_decor_sound() -> void:
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = _build_arpeggio_wav()
	player.volume_db = -6.0
	player.play()
	player.finished.connect(player.queue_free)


func _build_arpeggio_wav() -> AudioStreamWAV:
	var note_samples := int(SAMPLE_RATE * NOTE_DURATION)
	var total_samples := note_samples * ARPEGGIO_NOTES.size()
	var data := PackedByteArray()
	data.resize(total_samples * 2)

	for note_idx in range(ARPEGGIO_NOTES.size()):
		var freq: float = ARPEGGIO_NOTES[note_idx]
		var offset := note_idx * note_samples
		for i in range(note_samples):
			var t := float(i) / float(SAMPLE_RATE)
			var envelope := 1.0 - float(i) / float(note_samples)
			var sample := int(clamp(sin(TAU * freq * t) * envelope * 28000.0, -32768.0, 32767.0))
			data[( offset + i) * 2] = sample & 0xFF
			data[(offset + i) * 2 + 1] = (sample >> 8) & 0xFF

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = data
	return wav

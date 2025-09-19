extends Node

# Global Node to handle the sounds
const SOUND_PLAYER : Resource = preload('res://prefabs/system/default_sound_player.tscn')

func _ready() -> void:
	set_music(1)

func play_sound(audio : AudioStream, randomize_sound: bool = false, volume : float = 1.0) -> void :
	var stream : Node = SOUND_PLAYER.instantiate()
		
	stream.stream = audio
	stream.bus = "Sfx"
	if randomize_sound :
		stream.pitch_scale = randf_range(0.9, 1.1)
		stream.volume_db = linear_to_db(volume)*randf_range(0.9, 1.1)
	add_child(stream)
	stream.play()

func update_music() -> void :
	if not GameState.in_game :
		set_music(1)
		return
	if GameState.level_index < 2 :
		set_music(2)
		return
	if GameState.level_index < 4 :
		set_music(3)
		return
	if GameState.level_index < 8 :
		set_music(4)
		return
	if GameState.level_index < 12 :
		set_music(5)
		return
	set_music(6)

func set_music(music_index: int) -> void :
	for child_index in get_child_count() :
		var volume = 0.8 if music_index == child_index + 1 else 0.0
		if volume == get_child(child_index).volume_linear :
			continue
		var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(get_child(child_index), 'volume_linear', volume, 0.3)

extends Node2D

const DISCOVERY = preload("res://prefabs/env/discovery.tscn")
const FAITH_SOUND = preload("res://audio/sfx/faith.wav")

func _ready() -> void:
	if GameState.world_status != GameState.STATUS.INV_FAITH :
		for child in get_children() :
			child.queue_free()
		return
	for child in get_children() :
		child.hide()
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.9)
	tween.tween_callback(faith)

func faith() :	
	for child in get_children() :
		child.show()
		var discovery = DISCOVERY.instantiate()
		discovery.position = child.position
		add_child(discovery)
		discovery.emitting = true
		var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_interval(0.4)
		tween.tween_callback(discovery.queue_free)
	SoundManager.play_sound(FAITH_SOUND, true)

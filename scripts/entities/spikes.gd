extends Area2D

const DEATH_SOUND: Resource = preload("res://audio/sfx/death.wav")
const EXTEND_SOUND: Resource = preload("res://audio/sfx/pic qui fait mal.wav")

@export var ActionButton: Area2D

var extended = false

func _ready() -> void:
	if GameState.world_status == GameState.STATUS.CHAOS :
		var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_interval(0.9)
		tween.tween_callback(activate)
		return
	ActionButton.connect("toggled", toggled)

func _process(_delta: float) -> void:
	if not extended :
		return
	
	for body in get_overlapping_bodies() :
		if body.is_in_group("player") :
			body.die()
		if body.is_in_group("mob") :
			SoundManager.play_sound(DEATH_SOUND, true)
			body.die()

func toggled(state: bool) -> void :
	$sprite.region_rect.position.x = 16 if state else 0
	extended = state
	SoundManager.play_sound(EXTEND_SOUND, true)

func activate() -> void :
	toggled(true)

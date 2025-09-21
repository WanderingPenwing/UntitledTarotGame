extends Area2D

const DEATH_SOUND: Resource = preload("res://audio/sfx/death.wav")
const HURT_SOUND: Resource = preload("res://audio/sfx/hurt.wav")
const EXPLOSION_SOUND = preload("res://audio/sfx/explosion.wav")
const EXTEND_SOUND: Resource = preload("res://audio/sfx/pic qui fait mal.wav")

@export var ActionButton: Area2D

@export var extended = false

func _ready() -> void:
	if GameState.world_status == GameState.STATUS.CHAOS :
		var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_interval(0.9)
		tween.tween_callback(activate)
		return
	if ActionButton :
		ActionButton.connect("toggled", toggled)
	if extended :
		$sprite.region_rect.position.x = 16

func _process(_delta: float) -> void:
	if not extended :
		return
	
	for body in get_overlapping_bodies() :
		if body.is_in_group("player") :
			if GameState.player_status == GameState.STATUS.DEATH :
				queue_free()
				get_tree().get_first_node_in_group("world").explode(position)
				SoundManager.play_sound(EXPLOSION_SOUND)
			else :
				body.die()
		if body.is_in_group("mob") :
			if GameState.mob_status == GameState.STATUS.DEATH :
				queue_free()
				get_tree().get_first_node_in_group("world").explode(position)
				SoundManager.play_sound(EXPLOSION_SOUND)
			else :
				body.die()
				SoundManager.play_sound(HURT_SOUND)

func toggled(state: bool) -> void :
	$sprite.region_rect.position.x = 16 if state else 0
	extended = state
	SoundManager.play_sound(EXTEND_SOUND, true)

func activate() -> void :
	toggled(true)

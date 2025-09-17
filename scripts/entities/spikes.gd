extends Area2D

const DEATH_SOUND: Resource = preload("res://audio/sfx/death.wav")

@export var ActionButton: Area2D

var extended = false

func _ready() -> void:
	ActionButton.connect("toggled", toggled)

func _process(_delta: float) -> void:
	if not extended :
		return
	
	for body in get_overlapping_bodies() :
		if body.is_in_group("player") :
			get_tree().paused = true
			GameState.call_deferred("reset_level")
			SoundManager.play_sound(DEATH_SOUND, true)
		if body.is_in_group("mob") :
			SoundManager.play_sound(DEATH_SOUND, true)
			body.die()

func toggled(state: bool) -> void :
	$sprite.region_rect.position.x = 16 if state else 0
	extended = state

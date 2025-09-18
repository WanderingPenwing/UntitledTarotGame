extends Area2D

const WIN_SOUND : Resource = preload("res://audio/sfx/win2.wav")

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or body.position.distance_to(position) > 16 :
		return
	if body.type != body.TYPE.KING :
		return
	# si le joueur touche le drapeau on a gagneeeee
	GameState.win()
	SoundManager.play_sound(WIN_SOUND, true)

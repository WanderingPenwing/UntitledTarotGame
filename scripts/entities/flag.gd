extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") :
		return
	# si le joueur touche le drapeau on a gagneeeee
	GameState.win()
	

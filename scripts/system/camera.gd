extends Camera2D

@onready var Player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if not Player :
		return
	position = Player.position
	
	if Player.position.y < -56 :
		get_tree().paused = true
		$good.show()
	if Player.position.y > 166 :
		get_tree().paused = true
		$bad.show()

extends Camera2D

@onready var Player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if not Player :
		return
	position = Player.position

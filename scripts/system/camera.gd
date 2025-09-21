extends Camera2D

const keyartbadend = preload("res://prefabs/cutscene/cutscene scene/badend_keyart.tscn")
const keyartgoodend = preload("res://prefabs/cutscene/cutscene scene/goodend_keyart.tscn")

@onready var Player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if not Player :
		return
	position = Player.position
	
	if Player.position.y < -64 :
		get_tree().paused = true
		get_tree().change_scene_to_packed(keyartbadend)
		GameUi.reset_ui()
		GameState.in_game = false
		
	if Player.position.y > 174 :
		get_tree().paused = true
		get_tree().change_scene_to_packed(keyartgoodend)
		GameUi.reset_ui()
		GameState.in_game = false

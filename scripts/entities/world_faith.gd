extends Node2D


func _ready() -> void:	
	if GameState.world_status != GameState.STATUS.FAITH :
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
		if not child.is_in_group("door") :
			continue
		var Map: TileMapLayer = get_tree().get_first_node_in_group("world")
		var door_pos = Map.local_to_map(child.position)
		Map.set_cell(door_pos, 0, Vector2(1,0))

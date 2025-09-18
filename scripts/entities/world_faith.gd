extends Node2D


func _ready() -> void:
	if GameState.world_status == GameState.STATUS.FAITH :
		return
		
	for child in get_children() :
		child.queue_free()
		if not child.is_in_group("door") :
			continue
		var Map: TileMapLayer = get_tree().get_first_node_in_group("world")
		var door_pos = Map.local_to_map(child.position)
		Map.set_cell(door_pos, 0, Vector2(2,0))
